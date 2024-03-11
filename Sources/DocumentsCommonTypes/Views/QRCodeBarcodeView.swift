import UIKit
import Lottie
import DiiaCommonTypes
import DiiaUIComponents

/// design_system_code: docQROrg

public class QRCodeBarcodeView: BaseCodeView, FlippableEmbeddedView {
    
    // MARK: - Subviews
    private var animatorView = LottieAnimationView(name: "loader")
    
    private lazy var titleLabel = UILabel().withParameters(font: FontBook.cardsHeadingFont,
                                                           numberOfLines: 0,
                                                           lineBreakMode: .byWordWrapping)
    
    private lazy var errorView = UIView()
    
    private lazy var verificationView: VerificationView = VerificationView()
    
    private var viewModel: QRCodeViewModel?
    private var screenBrightnessService: ScreenBrightnessServiceProtocol? = DocumentsCommonConfiguration.shared.screenBrightnessService
    
    // MARK: - Setup
    public override func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = Constants.cornerRadius
        
        addSubview(verificationView)
        addSubview(titleLabel)
        addSubview(animatorView)
        
        verificationView.fillSuperview()
        verificationView.layer.cornerRadius = Constants.cornerRadius
        setupTitle()
        
        animatorView.withSize(Constants.loaderSize)
        animatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        animatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        animatorView.loopMode = .loop
        animatorView.backgroundBehavior = .pauseAndRestore
    }
    
    private func setupTitle() {
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: Constants.titleEdgeInset)
    }
    
    // MARK: - Configuration
    public func configure(viewModel: QRCodeViewModel) {
        self.viewModel = viewModel
        viewModel.holder = self
        viewModel.timerLabel = verificationView.expirationLabel
        verificationView.docType = viewModel.docType
        verificationView.localisation = viewModel.localization
        titleLabel.setTextWithCurrentAttributes(text: viewModel.docType?.name ?? "")
    }
    
    // MARK: - FlippableEmbeddedView
    public func willPresent() {
        viewModel?.loadCode()
    }
    
    public func willHide() {
        screenBrightnessService?.resetBrightness()
        viewModel?.cancel()
    }
    
    public func didHide() {
        verificationView.clear()
        setLoading(isActive: false)
    }
    
    // MARK: - Helping methods
    private func clearViews() {
        titleLabel.isHidden = true
        animatorView.isHidden = true
        errorView.removeFromSuperview()
        verificationView.clear()
        setLoading(isActive: false)
    }
    
    private func setupError(with emoji: String = "☝️", title: String, btnText: String? = nil, type: ErrorType) {
        errorView.removeFromSuperview()
        let stub = StubMessageViewV2()
        stub.translatesAutoresizingMaskIntoConstraints = false
        stub.configure(with: .init(icon: emoji, title: title, repeatAction: {[weak self] in
            self?.viewModel?.loadCode()
        }), titleFont: Constants.errorTextFont,
                       emojiFont: FontBook.bigEmoji,
                       buttonFont: Constants.errorTextFont)
        if btnText != nil {
            stub.configure(btnTitle: btnText ?? "",
                           titleFont: Constants.errorTextFont,
                           emojiFont: FontBook.bigEmoji,
                           buttonFont: Constants.errorTextFont)
        }
        
        let showView = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light),
                                                       intensity: 0.1)
        showView.translatesAutoresizingMaskIntoConstraints = false
        showView.contentView.backgroundColor = UIColor(white: 1, alpha: 0.95)
        showView.contentView.addSubview(stub)
        showView.layer.masksToBounds = true
        showView.layer.cornerRadius = Constants.cornerRadius
        addSubview(showView)
        
        if type == .global {
            showView.fillSuperview()
        } else {
            showView.topAnchor.constraint(equalTo: verificationView.expirationLabel.bottomAnchor).isActive = true
            showView.bottomAnchor.constraint(equalTo: verificationView.optionsStack.topAnchor).isActive = true
            showView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            showView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
        stub.centerYAnchor.constraint(equalTo: showView.centerYAnchor).isActive = true
        stub.leadingAnchor.constraint(equalTo: showView.leadingAnchor, constant: Constants.stubOffset).isActive = true
        stub.trailingAnchor.constraint(equalTo: showView.trailingAnchor, constant: -Constants.stubOffset).isActive = true
        
        errorView = showView
    }
    
    private func setup(qrLink: String, barcode: String?) {
        verificationView.fill(with: qrLink, barcode: barcode, selectedType: viewModel?.verificationType ?? .qr)
    }
    
    private func setLoading(isActive: Bool) {
        if isActive {
            animatorView.play()
        } else {
            animatorView.stop()
        }
        animatorView.isHidden = !isActive
    }
    
    private func configureAccessibility(for status: QRCodeStatus) {
        guard let viewModel = viewModel else { return }
        
        switch status {
        case .offline:
            verificationView.accessibilityLabel = R.Strings.documents_collection_accessibility_verification_view_offline.formattedLocalized(arguments: viewModel.docType?.name ?? "")
            verificationView.accessibilityHint = nil
            verificationView.configureAccessibility(on: self, isMainStackAvailable: false)
        case .ready:
            verificationView.accessibilityLabel = R.Strings.documents_collection_accessibility_verification_view.formattedLocalized(arguments: viewModel.docType?.name ?? "")
            verificationView.accessibilityHint = R.Strings.documents_collection_accessibility_verification_view_hint.localized()
        default:
            break
        }
    }
}

extension QRCodeBarcodeView: QRCodeHolder {
    public func statusChanged(status: QRCodeStatus) {
        switch status {
        case .offline:
            self.clearViews()
            let title = viewModel?.localization == .ua ?
            R.Strings.document_general_error_codes_not_loaded.localized() :
            R.Strings.document_general_error_codes_not_loaded_en.localized()
            let btnText = viewModel?.localization == .ua ?
            R.Strings.document_general_retry.localized() : R.Strings.document_general_retry_en.localized()
            self.setupError(title: title, btnText: btnText, type: .global)
        case .error(let viewModel):
            self.clearViews()
            self.setupError(with: viewModel.icon,
                            title: viewModel.title ?? "",
                            btnText: self.viewModel?.localization == .ua ?
                            R.Strings.document_general_retry.localized() : R.Strings.document_general_retry_en.localized(),
                            type: .global)
            
        case .expired:
            let title = viewModel?.localization == .ua ?
            R.Strings.error_code_expired.localized() : R.Strings.error_code_expired_en.localized()
            let btnText = viewModel?.localization == .ua ?
            R.Strings.general_update_code_action.localized() : R.Strings.general_update_code_action_en.localized()
            self.setupError(title: title,
                            btnText: btnText,
                            type: .qrExpiration)
        case .loading:
            self.clearViews()
            setLoading(isActive: true)
        case .ready(let link, let barcode):
            self.clearViews()
            setup(qrLink: link, barcode: barcode)
        }
        configureAccessibility(for: status)
    }
}

extension QRCodeBarcodeView {
    enum Constants {
        static let loaderSize = CGSize(width: 80, height: 80)
        static let errorViewHeight: CGFloat = 200
        static let loadingAnimationLength: TimeInterval = 1.5
        static let buttonHeight: CGFloat = 36
        static let buttonHorizontalInset: CGFloat = 19
        static let errorTextVerticalShift: CGFloat = -28
        static let verticalEmojiSpacing: CGFloat = 24
        static let errorVerticalSpacing: CGFloat = 24
        static let cornerRadius: CGFloat = 24
        static let stubOffset: CGFloat = 40
        static let titleEdgeInset = UIEdgeInsets(top: DocumentsLayoutProvider.topInset,
                                                 left: DocumentsLayoutProvider.sideSpacing,
                                                 bottom: 0,
                                                 right: DocumentsLayoutProvider.sideSpacing)
        static let errorTextFont: UIFont = {
            switch UIScreen.main.bounds.width {
            case 414, 428, 430:
                return FontBook.mainFont.regular.size(18)
            case 320:
                return FontBook.mainFont.regular.size(12)
            default:
                return FontBook.mainFont.regular.size(16)
            }
        }()
    }
    
    enum ErrorType {
        case global, qrExpiration
    }
}
