import UIKit
import DiiaUIComponents
import DiiaCommonTypes
import DiiaDocumentsCommonTypes

class DocumentActionSheetViewController: UIViewController, ChildSubcontroller {
    
    // MARK: - Properties
    weak var container: ContainerProtocol?
    
    private let containerView = UIView()
    private let scrollView = UIScrollView()
    private let actionStackView = UIStackView.create(views: [])
    private let codeStackView = UIStackView.create(.horizontal, views: [], distribution: .fillEqually)
    private var lastButtonSeparatorHeightConstraint: NSLayoutConstraint?
    private let lastButton = ActionButton()
    
    var actions: [[Action]] = [] {
        didSet {
            updateViews()
        }
    }
    
    var codeAction: ((VerificationType) -> Void)?
    
    var lastAction: Action = Action(title: R.Strings.general_accessibility_close.localized(),
                                    image: nil,
                                    callback: {}) {
        didSet {
            updateViews()
        }
    }
    
    var separatorColorStr: String = AppConstants.Colors.separatorColor {
        didSet {
            updateViews()
        }
    }
    
    var separatorParams = SeparatorParameters.init(padding: Constants.spacing,
                                                   height: Constants.separatorHeight) {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupAccessibility()
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        view.backgroundColor = .clear
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        
        view.addSubview(containerView)
        containerView.backgroundColor = .clear
        scrollView.backgroundColor = .white
        scrollView.layer.cornerRadius = Constants.cornerRadius
        
        containerView.anchor(top: nil,
                             leading: view.leadingAnchor,
                             bottom: view.safeAreaLayoutGuide.bottomAnchor,
                             trailing: view.trailingAnchor,
                             padding: .init(top: .zero,
                                            left: Constants.spacing,
                                            bottom: Constants.spacing,
                                            right: Constants.spacing)
        )
                
        containerView.addSubview(lastButton)
        lastButton.anchor(top: nil, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
        configureButton(button: lastButton, align: .center, font: FontBook.smallHeadingFont)
        
        containerView.addSubview(scrollView)
        scrollView.anchor(
            top: containerView.topAnchor,
            leading: containerView.leadingAnchor,
            bottom: lastButton.topAnchor,
            trailing: containerView.trailingAnchor,
            padding: .init(top: .zero, left: .zero, bottom: Constants.smallSpacing, right: .zero))
        
        scrollView.addSubview(actionStackView)
        actionStackView.fillSuperview()
        actionStackView.anchor(top: nil, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor)
        
        let stackHeightConstraint = actionStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        stackHeightConstraint.priority = .defaultLow
        stackHeightConstraint.isActive = true
        
        containerView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.spacing).isActive = true
    }
    
    private func updateViews() {
        actionStackView.safelyRemoveArrangedSubviews()
        
        lastButtonSeparatorHeightConstraint?.constant = separatorParams.height
        
        let firstView = BoxView(subview: UIView()).withConstraints(size: .init(width: actionStackView.frame.width, height: Constants.smallSpacing))
        firstView.subview.backgroundColor = .white
        actionStackView.addArrangedSubview(firstView)
        
        for (index, groupActions) in actions.enumerated() {
            for action in groupActions {
                actionStackView.addArrangedSubview(buttonForAction(action: action))
            }
            if index != (actions.endIndex - 1) {
                addSeparator(needSpacing: true)
            }
        }
        
        configureCodeView()
        
        let newLastAction = Action(title: lastAction.title, image: lastAction.image, callback: { [weak self] in
            self?.close()
            self?.lastAction.callback()
        })
        lastButton.action = newLastAction
        configureButton(button: lastButton, align: .center, font: FontBook.smallHeadingFont)
        lastButton.layer.cornerRadius = Constants.lastButtonCorner
        lastButton.backgroundColor = .white
        lastButton.contentHorizontalAlignment = .center
        lastButton.titleLabel?.textAlignment = .center
        configureAccessibility()
        
        view.layoutIfNeeded()
    }
    
    private func buttonForAction(action: Action) -> ActionButton {
        let newAction = Action(title: action.title, image: action.image, callback: { [weak self] in
            self?.close()
            action.callback()
        })
        let button = ActionButton(action: newAction, type: .full)
        configureButton(button: button, align: .left)
        return button
    }
    
    private func addSpacer() {
        let spacer = BoxView(subview: UIView()).withConstraints(
            size: .init(width: actionStackView.frame.width, height: Constants.spacerHeight))
        spacer.subview.backgroundColor = .clear
        actionStackView.addArrangedSubview(spacer)
    }
    
    private func addSeparator(needSpacing: Bool = false) {
        let separatorView = BoxView(subview: UIView()).withConstraints(
            insets: .init(top: 0, left: needSpacing ? Constants.spacing : 0, bottom: 0, right: needSpacing ? Constants.spacing : 0),
            size: .init(width: .zero, height: separatorParams.height))
        separatorView.subview.backgroundColor = Constants.separatorColor
        actionStackView.addArrangedSubview(separatorView)
    }
    
    private func configureCodeView() {
        guard codeAction != nil else {
            return
        }
        
        addSeparator()
        addSpacer()
        
        let qrOptionView = VerificationOptionView()
        qrOptionView.verificationType = .qr
        qrOptionView.setActive(true, localization: .ua)
        qrOptionView.onTap = {[weak self] in
            self?.codeAction?(.qr)
            self?.close()
        }
        
        let barcodeOptionView = VerificationOptionView()
        barcodeOptionView.verificationType = .barcode
        barcodeOptionView.setActive(true, localization: .ua)
        barcodeOptionView.onTap = {[weak self] in
            self?.codeAction?(.barcode)
            self?.close()
        }
        
        codeStackView.addArrangedSubviews([qrOptionView, barcodeOptionView])
        codeStackView.withHeight(Constants.codeHeight)
        actionStackView.addArrangedSubview(codeStackView)
        
        let boxView = BoxView(subview: UIView()).withConstraints(size: .init(width: actionStackView.frame.width,
                                                                             height: Constants.actionViewHeight))
        boxView.subview.backgroundColor = .clear
        actionStackView.addArrangedSubview(boxView)
    }
    
    private func configureButton(button: ActionButton,
                                 align: UIControl.ContentHorizontalAlignment,
                                 font: UIFont = FontBook.bigText) {
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = font
        button.contentHorizontalAlignment = align
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = .init(top: Constants.spacing,
                                         left: Constants.defaultSpacing,
                                         bottom: Constants.spacing,
                                         right: Constants.spacing)
        if button.action?.title == nil || button.action?.title?.count == 0 {
            button.iconRenderingMode = .alwaysTemplate
            button.imageView?.tintColor = UIColor(separatorColorStr)
        } else {
            button.iconRenderingMode = .alwaysOriginal
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byWordWrapping
            if button.action?.image != nil {
                button.contentHorizontalAlignment = align
                button.titleEdgeInsets = Constants.textPadding
                button.contentEdgeInsets = .init(top: Constants.spacing,
                                                 left: Constants.defaultSpacing,
                                                 bottom: Constants.spacing,
                                                 right: Constants.spacing)
            }
        }
        button.withHeight(Constants.buttonHeight)
    }
    
    private func setupAccessibility() {
        lastButton.accessibilityLabel = R.Strings.general_accessibility_close.localized()
    }
    
    private func configureAccessibility() {
        UIAccessibility.post(notification: .layoutChanged, argument: actionStackView.subviews.first)
    }
    
    // MARK: - Actions
    @objc private func close() {
        container?.close()
    }
}

// MARK: - Constants
extension DocumentActionSheetViewController {
    private enum Constants {
        static let actionViewHeight: CGFloat = 24
        static let spacerHeight: CGFloat = 16
        static let separatorColor = UIColor.black.withAlphaComponent(0.07)
        static let codeHeight: CGFloat = 80
        static let cornerRadius: CGFloat = 24
        static let buttonHeight: CGFloat = 56
        static let lastButtonCorner: CGFloat = 28
        static let spacing: CGFloat = 16
        static let defaultSpacing: CGFloat = 32
        static let textPadding = UIEdgeInsets(top: 20,
                                              left: 20,
                                              bottom: 20,
                                              right: 20)
        static let smallSpacing: CGFloat = spacing / 2
        static let minimalSpacing: CGFloat = smallSpacing / 2
        static let separatorHeight: CGFloat = 1
    }
}
