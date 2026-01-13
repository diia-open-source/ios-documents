
import UIKit
import DiiaUIComponents
import DiiaCommonTypes

// MARK: - VerificationOptionView

/// design_system_code:  btnToggleMlc
///
public final class VerificationOptionView: BaseCodeView {
    
    // MARK: - Subviews
    lazy var iconImageView: UIImageView = UIImageView()
    
    lazy var titleLabel = UILabel().withParameters(font: FontBook.bigText)
    
    // MARK: - Properties
    public var verificationType: VerificationType = .qr {
        didSet {
            titleLabel.text = verificationType == .qr ? R.Strings.general_qr_code.localized() : R.Strings.general_barcode.localized()
        }
    }
    
    public var onTap: Callback?
    
    // MARK: - LifeCycle
    public override func setupSubviews() {
        addSubview(titleLabel)
        addSubview(iconImageView)
        
        setupConstraints()
        setupRecognizer()
        setupUI()
        setupAccessibility()
    }
    
    private func setupUI() {
        titleLabel.textAlignment = .center
    }
    
    private func setupConstraints() {
        titleLabel.anchor(top: nil,
                          leading: leadingAnchor,
                          bottom: bottomAnchor,
                          trailing: trailingAnchor)
        titleLabel.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor).isActive = true
        iconImageView.anchor(top: topAnchor,
                             leading: nil,
                             bottom: titleLabel.topAnchor,
                             trailing: nil,
                             padding: UIEdgeInsets(top: .zero,
                                                   left: .zero,
                                                   bottom: Constants.iconBottomInset,
                                                   right: .zero
                                                  ),
                             size: CGSize(width: Constants.iconSize, height: Constants.iconSize))
    }
    
    private func setupRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        isUserInteractionEnabled = true
        addGestureRecognizer(recognizer)
    }
    
    // MARK: - Private Methods
    @objc private func viewTapped() {
        onTap?()
    }
    
    // MARK: - Accessibility
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
    
    // MARK: - Public Methods
    public func setActive(_ isActive: Bool, localization: LocalizationType) {
        switch verificationType {
        case .barcode:
            titleLabel.text = localization == .ua ? R.Strings.general_barcode.localized() : R.Strings.document_general_barcode_en.localized()
            accessibilityLabel = localization == .ua ? R.Strings.general_barcode.localized() : R.Strings.document_general_barcode_en.localized()
        case .qr:
            titleLabel.text = localization == .ua ? R.Strings.general_qr_code.localized() : R.Strings.document_general_qr_code_en.localized()
            accessibilityLabel = localization == .ua ? R.Strings.general_qr_code.localized() : R.Strings.document_general_qr_code_en.localized()
        }
        
        let iconActive = verificationType == .qr ? R.Image.qrCodeActive.image : R.Image.barcodeActive.image
        let iconInactive = verificationType == .qr ? R.Image.qrCodeInactive.image : R.Image.barcodeInactive.image
        iconImageView.image = isActive ? iconActive : iconInactive
    }
}

// MARK: - Constants
extension VerificationOptionView {
    private enum Constants {
        static let iconSize: CGFloat = 52
        static let iconBottomInset: CGFloat = 12
    }
}
