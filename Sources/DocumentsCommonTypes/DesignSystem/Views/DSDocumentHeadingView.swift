import UIKit
import DiiaCommonTypes
import DiiaUIComponents

/// design_system_code: docHeadingOrg

public class DSDocumentHeadingView: BaseCodeView {
    
    private var stackView = UIStackView.create(views: [], spacing: Constants.spacing)
    
    private lazy var ellipseButton: UIButton = {
        let button = UIButton()
        button.isExclusiveTouch = true
        button.isHidden = true
        button.contentEdgeInsets = Constants.imageInset
        return button
    }()
    
    private var buttonCallback: Callback?
    
    public override func setupSubviews() {
        hstack(stackView,
               ellipseButton,
               alignment: .bottom,
               distribution: .fillProportionally,
               padding: Constants.padding)
        
        ellipseButton.withSize(Constants.buttonSize)
        ellipseButton.addTarget(self, action: #selector(ellipseButtonAction), for: .touchUpInside)
    }
    
    public func configure(model: DSDocumentHeading) {
        if let headingWithSubtitlesMlc = model.headingWithSubtitlesMlc {
            let headerView = DSHeadingWithSubtitleView()
            headerView.configure(model: headingWithSubtitlesMlc)
            stackView.addArrangedSubview(headerView)
        }
        if let headingWithSubtitlesMlc = model.headingWithSubtitleWhiteMlc {
            let headerView = DSHeadingWithSubtitleView()
            headerView.configure(model: headingWithSubtitlesMlc)
            headerView.setupUI(textColor: .white, font: FontBook.cardsHeadingFont)
            stackView.addArrangedSubview(headerView)
        }
        if let item = model.docNumberCopyMlc {
            let itemView = DSTableItemPrimaryView()
            itemView.configure(model: item)
            itemView.setupUI(numberOfLines: 1)
            stackView.addArrangedSubview(itemView)
        }
        if let item = model.docNumberCopyWhiteMlc {
            let itemView = DSTableItemPrimaryView()
            itemView.configure(model: item)
            itemView.setupUI(textColor: .white, valueFont: Constants.fixedFontSize, numberOfLines: 1)
            stackView.addArrangedSubview(itemView)
        }
        if let iconAtm = model.iconAtm {
            let imageProvider = DocumentsCommonConfiguration.shared.imageProvider
            ellipseButton.setImage(imageProvider?.imageForCode(imageCode: iconAtm.code), for: .normal)
            ellipseButton.accessibilityHint = iconAtm.accessibilityDescription
        }
        ellipseButton.isHidden = model.iconAtm == nil
    }
    
    public func configureAction(_ callback: Callback?) {
        buttonCallback = callback
        let needHideBtn = ellipseButton.isHidden || callback == nil
        ellipseButton.alpha = needHideBtn ? 0 : 1
    }
    
    @objc private func ellipseButtonAction(_ sender: UIButton) {
        buttonCallback?()
    }
}

extension DSDocumentHeadingView {
    enum Constants {
        static let padding = UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16)
        static let imageInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 0)
        static let spacing: CGFloat = 8
        static let buttonSize = CGSize(width: 44, height: 44)
        static let fixedFontSize = FontBook.mainFont.regular.size(29)
    }
}
