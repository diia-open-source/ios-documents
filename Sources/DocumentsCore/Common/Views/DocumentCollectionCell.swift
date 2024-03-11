import UIKit
import DiiaCommonTypes
import DiiaUIComponents
import DiiaDocumentsCommonTypes

// MARK: - ViewModel
struct DocumentCollectionCellViewModel {
    let documentData: MultiDataType<DocumentModel>
    let contextMenuCallback: Callback?
    let cardStackCallback: Callback?
}

// MARK: - Cell
final class DocumentCollectionCell: UICollectionViewCell, Reusable, FlipperVerifyProtocol {
    private var frontContainer: UIView = UIView()
    private var backflipContainer: UIView = UIView()
    
    private var fullCardView: UIView = UIView()
    private var containerView: UIView = UIView()
    private var shadowView: UIView = UIView()

    private var backView: FlippableEmbeddedView?
    private var frontView: FlippableEmbeddedView?
    
    private let bottomCardView: UIView = UIView()
    private let bottomCardShadowView: UIView = UIView()
    
    private lazy var cardStackLabel: UILabel = {
        let label = UILabel().withParameters(font: FontBook.usualFont)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var cardStackIcon = UIImageView(image: R.Image.ds_stack.image)
    
    private lazy var cardStackView: UIView = {
        let stack = UIStackView(arrangedSubviews: [
            cardStackIcon.withSize(Constants.cardStackIconSize),
            BoxView(subview: cardStackLabel).withConstraints(centeredY: true)
        ])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = Constants.cardStackSpacing
        
        let box = BoxView(subview: stack).withConstraints(insets: Constants.cardStackInsets)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardStackClick))
        box.addGestureRecognizer(tap)
        box.isUserInteractionEnabled = true
        
        return box
    }()
    
    override var reuseIdentifier: String { DocumentCollectionCell.reuseID }
    
    private var viewModel: DocumentCollectionCellViewModel?
    
    var isFlipped: Bool { frontContainer.isHidden }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        contentView.addSubview(bottomCardShadowView)
        bottomCardShadowView.anchor(
            top: nil,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: Constants.bottomCardShadowInsets,
            size: .init(width: 0, height: Constants.bottomCardHeight))

        bottomCardShadowView.backgroundColor = .white
        bottomCardShadowView.alpha = Constants.alphaBackColor
        bottomCardShadowView.layer.cornerRadius = Constants.cornerRadius
        bottomCardShadowView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        fullCardView.addSubview(shadowView)
        shadowView.fillSuperview(padding: .init(top: Constants.generalInset,
                                                left: Constants.generalInset,
                                                bottom: Constants.generalInset,
                                                right: Constants.generalInset))
        
        contentView.addSubview(fullCardView)
        fullCardView.fillSuperview()
        fullCardView.backgroundColor = .clear
        
        fullCardView.addSubview(containerView)
        containerView.fillSuperview(padding: .init(top: 0,
                                                   left: 0,
                                                   bottom: Constants.bottomCardHeight,
                                                   right: 0))
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.addSubview(backflipContainer)
        containerView.backgroundColor = .clear
        containerView.clipsToBounds = true
        backflipContainer.fillSuperview()
        backflipContainer.backgroundColor = .clear
        containerView.addSubview(frontContainer)
        frontContainer.fillSuperview()
        frontContainer.backgroundColor = .clear
        frontContainer.addSubview(cardStackView)
        
        cardStackView.anchor(top: nil,
                             leading: nil,
                             bottom: frontContainer.bottomAnchor,
                             trailing: frontContainer.trailingAnchor)
        
        shadowView.layer.applySketchShadow(
            color: Constants.shadowColor,
            alpha: 1,
            y: Constants.shadowYOffset,
            blur: Constants.shadowBlur)
        
        backflipContainer.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.removeAllAnimations()
    }
    
    private func setupFrontView(frontView: FrontViewProtocol) {
        self.frontView = frontView
        frontView.contextMenuCallback = viewModel?.contextMenuCallback
        
        frontContainer.addSubview(frontView)
        frontView.fillSuperview()
    }
    
    private func setupBackView(backView: FlippableEmbeddedView) {
        self.backView?.removeFromSuperview()
        self.backView = nil
        self.backView = backView
        backflipContainer.addSubview(backView)
        backView.fillSuperview()
    }
    
    func configure(with viewModel: DocumentCollectionCellViewModel) {
        backView = nil
        frontView = nil
        backflipContainer.isHidden = true
        frontContainer.isHidden = false
        frontContainer.subviews.forEach { if $0 != cardStackView { $0.removeFromSuperview() } }
        backflipContainer.subviews.forEach { $0.removeFromSuperview() }
        
        self.viewModel = viewModel
        configureFront(with: viewModel.documentData.getValue())
        
        switch viewModel.documentData {
        case .single:
            bottomCardView.isHidden = true
            bottomCardShadowView.isHidden = true
            cardStackView.isHidden = true
        case .multiple(let items):
            bottomCardView.isHidden = false
            bottomCardShadowView.isHidden = false
            cardStackView.isHidden = false
            setupStackIcon(viewModel.documentData.getValue().docType?.stackIconAppearance)
            cardStackLabel.text = String(items.count)
            frontContainer.bringSubviewToFront(cardStackView)
        }
    }
    
    private func setupStackIcon(_ appearance: DocumentStackIconAppearance?) {
        cardStackIcon.image = appearance?.image
        cardStackLabel.textColor = appearance?.color
    }
    
    private func configureFront(with document: DocumentModel) {
        setupFrontView(frontView: document.frontView)
    }
    
    func setBackgroundColor(color: UIColor?) {
        containerView.backgroundColor = color ?? .white
        bottomCardView.backgroundColor = color ?? .white
    }
    
    // MARK: - Actions
    func flip(for type: VerificationType? = nil) {
        bottomCardShadowView.isHidden = true
        guard let document = viewModel?.documentData.getValue() else { return }
        
        if !frontContainer.isHidden {
            let backFlipAction: Callback = { [weak self] in self?.flip(for: type) }
            if let backView = document.backView(for: type, flippingAction: backFlipAction) {
                setupBackView(backView: backView)
            } else {
                return
            }
        }
        let currentView = frontContainer.isHidden ? backView : frontView
        let nextView = frontContainer.isHidden ? frontView : backView
        
        currentView?.willHide()
        nextView?.willPresent()
        
        UIView.transition(
            with: fullCardView,
            duration: Constants.flipAnimationDuration,
            options: .transitionFlipFromLeft,
            animations: {
                self.frontContainer.isHidden = !self.frontContainer.isHidden
                self.backflipContainer.isHidden = !self.backflipContainer.isHidden
            },
            completion: { [weak self, weak currentView] _ in
                currentView?.didHide()
                self?.bottomCardShadowView.isHidden = self?.cardStackView.isHidden == true
            }
        )
    }
    
    func shouldHide() {
        if !backflipContainer.isHidden {
            flip()
        }
    }
    
    func changeFocusing(isFocused: Bool) {
        if let currentView = frontContainer.isHidden ? backView : frontView {
            currentView.didChangeFocus(isFocused: isFocused)
        }
        isUserInteractionEnabled = isFocused
    }
    
    func setContentHidden(isHidden: Bool, animated: Bool = true) {
        let currentView = frontContainer.isHidden ? backflipContainer : frontContainer.subviews.first(where: {$0 is FrontViewProtocol})
        currentView?.layer.removeAllAnimations()
        let alpha: CGFloat = isHidden ? 0 : 1
        if currentView?.subviews.first?.alpha != alpha {
            if animated {
                UIView.animate(
                    withDuration: Constants.hideAnimationDuration,
                    delay: 0.0,
                    options: [.allowUserInteraction],
                    animations: { [weak currentView] in currentView?.subviews.forEach({$0.alpha = alpha}) }
                )
            } else {
                currentView?.subviews.forEach({$0.alpha = alpha})
            }
        }
    }
    
    @objc private func cardStackClick() {
        viewModel?.cardStackCallback?()
    }
}

extension DocumentCollectionCell {
    private enum Constants {
        static let hideAnimationDuration: TimeInterval = 0.3
        static let flipAnimationDuration: TimeInterval = 0.4
        static let alphaBackColor: CGFloat = 0.24
        static let shadowColor = UIColor.white
        static let shadowYOffset: CGFloat = 8
        static let shadowBlur: CGFloat = 23
        static let generalInset: CGFloat = 24
        static let cornerRadius: CGFloat = 24
        
        static let cardStackIconSize: CGSize = .init(width: 24, height: 24)
        static let cardStackSpacing: CGFloat = 4
        static let cardStackInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 32, right: 24)
        static let bottomCardHeight: CGFloat = 8
        static let bottomCardInsets: UIEdgeInsets = .init(top: 40, left: 8, bottom: 24, right: 8)
        static let bottomCardShadowInsets: UIEdgeInsets = .init(top: 80, left: 16, bottom: 0, right: 16)
    }
}
