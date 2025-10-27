import UIKit
import DiiaCommonTypes
import DiiaUIComponents

/// design_system_code: verificationCodesOrg

final class VerificationView: BaseCodeView {
    
    // MARK: - Subviews
    private var mainStackView = UIStackView.create(.vertical, views: [], spacing: Constants.verticalSpacing)
    
    public var expirationLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.expirationLblFont
        label.text = R.Strings.document_general_qr_session_time.localized()
        label.alpha = Constants.expirationAlpha
        label.textAlignment = .center
        return label
    }()
    
    private var qrCodeImageView: UIImageView = UIImageView()
    private var barcodeImageView: UIImageView = UIImageView()
    
    public var optionsStack: UIStackView = UIStackView.create(.horizontal, views: [], spacing: 8, distribution: .fillEqually)
    
    private lazy var qrOptionView: VerificationOptionView = {
        let view = VerificationOptionView()
        view.verificationType = .qr
        view.onTap = { [weak self] in self?.onVerificationTypeSelected(.qr) }
        return view
    }()
    
    private lazy var barcodeOptionView: VerificationOptionView = {
        let view = VerificationOptionView()
        view.verificationType = .barcode
        view.onTap = { [weak self] in self?.onVerificationTypeSelected(.barcode) }
        return view
    }()
    
    private var barcodeNumberLabel = UILabel().withParameters(font: FontBook.bigText)
    
    private var topConstants: NSLayoutConstraint?
    private var leadingConstants: NSLayoutConstraint?
    private var trailingConstants: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    // MARK: - Properties
    var docType: DocumentAttributesProtocol?
    var localisation: LocalizationType = .ua
    private var screenBrightnessService: ScreenBrightnessServiceProtocol? = DocumentsCommonConfiguration.shared.screenBrightnessService
    
    // MARK: - LifeCycle
    override func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        
        barcodeNumberLabel.textAlignment = .center
        
        mainStackView.addArrangedSubviews([expirationLabel, qrCodeImageView, barcodeImageView, barcodeNumberLabel])
        mainStackView.setCustomSpacing(Constants.barcodeSpacing, after: barcodeImageView)
        
        optionsStack.addArrangedSubviews([qrOptionView, barcodeOptionView])
        
        addSubview(mainStackView)
        addSubview(optionsStack)
        
        topConstants = mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topQRConstants)
        leadingConstants = mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.defaultPadding)
        trailingConstants = mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultPadding)
        
        qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor).isActive = true
        barcodeImageView.widthAnchor.constraint(equalTo: qrCodeImageView.widthAnchor).isActive = true
        barcodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor, multiplier: Constants.barcodeMultiply).isActive = true
        
        topConstants?.isActive = true
        leadingConstants?.isActive = true
        trailingConstants?.isActive = true
        
        optionsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.defaultPadding).isActive = true
        optionsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.defaultPadding).isActive = true
        optionsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.defaultPadding).isActive = true
        bottomConstraint = optionsStack.topAnchor.constraint(greaterThanOrEqualTo: mainStackView.bottomAnchor, constant: Constants.barcodeSpacing)
        bottomConstraint?.isActive = true
        
        setupAccessibility()
    }
    
    // MARK: - Public Methods
    func clear() {
        qrCodeImageView.image = nil
        barcodeImageView.image = nil
        barcodeNumberLabel.text = nil
        optionsStack.isHidden = true
        expirationLabel.isHidden = true
    }
    
    func fill(with qrLink: String, barcode: String?, selectedType: VerificationType) {
        expirationLabel.isHidden = false
        qrCodeImageView.image = .qrCode(from: qrLink)
        optionsStack.isHidden = barcode == nil
        qrCodeImageView.isHidden = selectedType == .qr
        
        backgroundColor = .white
        
        guard let barcode = barcode, let barcodeImage = UIImage.barcode(from: barcode) else {
            onVerificationTypeSelected(selectedType)
            topConstants?.constant = bounds.height/2 - mainStackView.bounds.height/2
            bottomConstraint?.isActive = false
            layoutIfNeeded()
            return
        }
        
        barcodeImageView.image = barcodeImage
        barcodeNumberLabel.attributedText = NSMutableAttributedString(string: separateBarcode(code: barcode),
                                                                      attributes: [NSAttributedString.Key.kern: 4])
        
        onVerificationTypeSelected(selectedType)
    }
    
    func configureAccessibility(on view: UIView, isMainStackAvailable: Bool) {
        if view.accessibilityElements?.first(where: { $0 as? UIView == mainStackView }) == nil {
            view.accessibilityElements?.append(mainStackView)
        }
        mainStackView.isAccessibilityElement = isMainStackAvailable
    }
    
    func changeVerificationView(for verificationType: VerificationType) {
        onVerificationTypeSelected(verificationType)
    }
    
    // MARK: - Private Methods
    private func onVerificationTypeSelected(_ verificationType: VerificationType) {
        guard let docType = self.docType else { return }
        
        let isQRCode = verificationType == .qr
        
        qrCodeImageView.isHidden = !isQRCode
        barcodeImageView.isHidden = isQRCode
        barcodeNumberLabel.isHidden = isQRCode
        
        barcodeOptionView.setActive(!isQRCode, localization: localisation)
        qrOptionView.setActive(isQRCode, localization: localisation)
        
        topConstants?.constant = isQRCode ? Constants.topQRConstants : Constants.topBarPadding
        leadingConstants?.constant = isQRCode ? Constants.defaultPadding : Constants.barcodePadding
        trailingConstants?.constant = isQRCode ? -Constants.defaultPadding : -Constants.barcodePadding
        
        switch verificationType {
        case .qr:
            if docType.isStaticDoc {
                expirationLabel.text = ""
            }
            screenBrightnessService?.resetBrightness()
        case .barcode:
            screenBrightnessService?.increaseBrightness()
        }
        layoutIfNeeded()
    }
    
    private func setupAccessibility() {
        mainStackView.accessibilityLabel = R.Strings.document_general_qr_session_time.localized()
        mainStackView.accessibilityTraits = .staticText
    }
    
    private func separateBarcode(code: String) -> String {
        let stride: Int = 4
        let separator: String = "  "
        if code.count < stride / 2 { return code }
        var result = ""
        var counter = 0
        while counter < 2 {
            for index in (counter * stride)..<((counter+1) * stride) {
                result += code.character(at: index) ?? ""
            }
            result += separator
            counter += 1
        }
        for index in (counter * stride)..<code.count {
            result += code.character(at: index) ?? ""
        }
        return result
    }
    
}

// MARK: - Constants
extension VerificationView {
    private enum Constants {
        static let barcodeMultiply: CGFloat = 0.4
        static let topBarPadding: CGFloat = 100
        static let defaultPadding: CGFloat = 40
        static let topQRConstants: CGFloat = 48
        static let barcodePadding: CGFloat = 32
        static let verticalSpacing: CGFloat = 16
        static let barcodeSpacing: CGFloat = 12
        static let expirationAlpha: CGFloat = 0.5
        static var horizontalInset: CGFloat {
            switch UIDevice.size() {
            case .screen4Inch:
                return 48
            default:
                return 40
            }
        }
        static var expirationLblFont: UIFont = {
            switch UIScreen.main.bounds.width {
            case 414, 428, 430:
                return FontBook.mainFont.regular.size(12)
            case 320:
                return FontBook.mainFont.regular.size(9)
            default:
                return FontBook.mainFont.regular.size(11)
            }
        }()
    }
}
