import UIKit
import Lottie
import DiiaUIComponents
import DiiaCommonTypes

public enum DSDocumentState {
    case ready
    case loading
}

public class DSDocumentWithPhotoViewModel {
    public var model: DSDocumentData?
    public var images: [DSDocumentContentData: UIImage]?
    public var docType: DocumentAttributesProtocol?
    public var errorViewModel: DocumentErrorViewModel?
    
    public init(
        model: DSDocumentData? = nil,
        images: [DSDocumentContentData : UIImage]? = nil,
        docType: DocumentAttributesProtocol? = nil,
        errorViewModel: DocumentErrorViewModel? = nil
    ) {
        self.model = model
        self.images = images
        self.docType = docType
        self.errorViewModel = errorViewModel
    }
}

public class DSDocumentWithPhotoView: BaseCodeView, FrontViewProtocol {
    private weak var eventsHandler: DSConstructorEventHandler?

    private let docHeadingView = DSDocumentHeadingView()
    private let tableBlockTwoColumnsView = DSTableBlockTwoColumnsPlaneOrgView()
    private let tableBlockPlaneView = DSTableBlockPlaneOrgView()
    private let tickerAtm = DSTickerView()
    private let boosterView = SmallButtonPanelMlcView()
    private let docBottomView = DSDocumentHeadingView()
    private let subtitleLabel = BoxView(subview: UILabel().withParameters(font: FontBook.smallHeadingFont))
        .withConstraints(insets: Constants.subTitleInset)
    private var verticalStack = UIStackView.create(views: [])
    private let containerView = UIView()
    private let loadingView = BoxView(subview: LottieAnimationView(name: "loader"))
        .withConstraints(
            size: Constants.loaderSize,
            centeredX: true,
            centeredY: true
        )

    private lazy var errorView = DocumentErrorView()
    private lazy var tickerWrapperStackView = UIStackView.create(.horizontal, views: [tickerAtm])
    
    public var contextMenuCallback: Callback? {
        didSet {
            docBottomView.configureAction(contextMenuCallback)
        }
    }
    
    public override func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        tableBlockTwoColumnsView.translatesAutoresizingMaskIntoConstraints = false
        tickerWrapperStackView.translatesAutoresizingMaskIntoConstraints = false
        tableBlockPlaneView.translatesAutoresizingMaskIntoConstraints = false
        docBottomView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.fillSuperview()

        containerView.addSubview(tableBlockTwoColumnsView)
        containerView.addSubview(tickerWrapperStackView)
        containerView.addSubview(docBottomView)
        containerView.addSubview(boosterView)

        verticalStack = UIStackView.create(.vertical,
                                           views: [docHeadingView, subtitleLabel],
                                           spacing: 0)

        containerView.addSubview(verticalStack)
        containerView.addSubview(tableBlockPlaneView)

        verticalStack.anchor(top: topAnchor,
                             leading: leadingAnchor,
                             trailing: trailingAnchor,
                             padding: .init(top: Constants.verticalPadding,
                                            left: 0,
                                            bottom: 0,
                                            right: 0))

        tableBlockTwoColumnsView.anchor(top: verticalStack.bottomAnchor,
                                        leading: leadingAnchor,
                                        trailing: trailingAnchor,
                                        padding: .init(top: Constants.verticalPadding,
                                                       left: 0,
                                                       bottom: 0,
                                                       right: 0))

        tableBlockPlaneView.anchor(top: verticalStack.bottomAnchor,
                                   leading: leadingAnchor,
                                   trailing: trailingAnchor,
                                   padding: .init(top: Constants.customSpacing,
                                                  left: 0,
                                                  bottom: 0,
                                                  right: 0))
        
        let topPlaneTableConstraint = tickerWrapperStackView.topAnchor.constraint(
            greaterThanOrEqualTo: tableBlockPlaneView.bottomAnchor,
            constant: Constants.verticalTickerPadding
        )
        topPlaneTableConstraint.priority = .defaultHigh
        topPlaneTableConstraint.isActive = true
        
        let topTwoColumnTableConstraint = tickerWrapperStackView.topAnchor.constraint(
            greaterThanOrEqualTo: tableBlockTwoColumnsView.bottomAnchor,
            constant: Constants.verticalTickerPadding
        )
        topTwoColumnTableConstraint.priority = .defaultHigh
        topTwoColumnTableConstraint.isActive = true

        tickerWrapperStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        tickerWrapperStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
     
        docBottomView.topAnchor.constraint(greaterThanOrEqualTo: tickerWrapperStackView.bottomAnchor,
                                           constant: Constants.verticalTickerPadding).isActive = true

        boosterView.anchor(leading: leadingAnchor,
                            bottom: tickerWrapperStackView.topAnchor,
                             trailing: trailingAnchor,
                             padding: .init(top: 0,
                                            left: Constants.planePadding,
                                            bottom: Constants.planePadding,
                                            right: Constants.planePadding))
        
        docBottomView.anchor(leading: leadingAnchor,
                             bottom: bottomAnchor,
                             trailing: trailingAnchor,
                             padding: .init(top: 0,
                                            left: 0,
                                            bottom: Constants.bottomHeadingPaddding,
                                            right: 0))

        backgroundColor = UIColor.init(white: 1.0, alpha: 0.4)
        
        boosterView.isHidden = true
        docHeadingView.isHidden = true
        tableBlockTwoColumnsView.isHidden = true
        tableBlockPlaneView.isHidden = true
        docBottomView.isHidden = true
        subtitleLabel.isHidden = true
        containerView.alpha = Constants.visibleContainerViewAlpha
        setupErrorView()
        setupLoadingView()
        setupAccessibility()
    }
    
    /// - Parameters:
    ///   - viewModel: The viewModel to be processed. Can be `nil` if not applicable.
    ///   - shouldStopAfterErrorConfigured: A boolean flag indicating whether the configuring nested views should stop immediately if an `modelData.errorViewModel` exists and configured.
    ///   - insuranceTicker: An optional specific insurance ticker for handling events in `FloatingTextLabel`. Defaults to `nil`.
    public func configure(for viewModel: DSDocumentWithPhotoViewModel?,
                          shouldStopAfterErrorConfigured: Bool = true,
                          insuranceTicker: DSTickerAtom? = nil) {
        guard let viewModel, let data = viewModel.model else {
            return
        }

        guard let frontCard = viewModel.model?.currentLocalization() == .ua ? data.frontCard?.UA : data.frontCard?.EN else {
            return
        }

        if let docHeading = frontCard.first(where: {$0.docHeadingOrg != nil})?.docHeadingOrg {
            docHeadingView.configure(model: docHeading)
            docHeadingView.isHidden = false
            accessibilityLabel = docHeading.headingWithSubtitlesMlc?.value ?? docHeading.headingWithSubtitleWhiteMlc?.value
        }
        if let errorVM = viewModel.errorViewModel {
            errorView.isHidden = false
            errorView.configure(with: errorVM)
            configureForError(for: viewModel.model?.docData.fullName?.replacingOccurrences(of: " ", with: "\n"))
            if shouldStopAfterErrorConfigured { return }
        }
        let imagesContent = viewModel.images
        if let tableBlockTwoColumnsPlane = frontCard.first(where: {$0.tableBlockTwoColumnsPlaneOrg != nil})?.tableBlockTwoColumnsPlaneOrg {
            tableBlockTwoColumnsView.configure(models: tableBlockTwoColumnsPlane, imagesContent: imagesContent ?? [:])
            tableBlockTwoColumnsView.isHidden = false
        }
        if let ticker = frontCard.first(where: {$0.tickerAtm != nil})?.tickerAtm {
            configureTicker(ticker)
            tickerAtm.isHidden = false
        } else if let insuranceTicker {
            configureTicker(insuranceTicker)
            tickerAtm.isHidden = false
        } else {
            tickerAtm.isHidden = true
        }
        
        if let docButtonHeadingOrg = frontCard.first(where: {$0.docButtonHeadingOrg != nil})?.docButtonHeadingOrg {
            docBottomView.configure(model: docButtonHeadingOrg)
            docBottomView.isHidden = false
        }
        if let subtitleMlc = frontCard.first(where: {$0.subtitleLabelMlc != nil})?.subtitleLabelMlc {
            subtitleLabel.subview.text = subtitleMlc.label
            subtitleLabel.isHidden = false
        }
        if let tableBlockOrg = frontCard.first(where: {$0.tableBlockPlaneOrg != nil})?.tableBlockPlaneOrg {
            tableBlockPlaneView.configure(for: tableBlockOrg) { [weak self] event in
                self?.eventsHandler?.handleEvent(event: event)
            }
            tableBlockPlaneView.isHidden = false
        }
        if let boosterMlc = frontCard.first(where: {$0.smallEmojiPanelMlc != nil})?.smallEmojiPanelMlc {
            boosterView.configure(for: boosterMlc)
            boosterView.isHidden = false
        }
    }

    public func setEventsHandler(_ eventsHandler: DSConstructorEventHandler) {
        self.eventsHandler = eventsHandler
    }

    public func setLoadingState(_ state: DSDocumentState) {
        setLoading(isActive: state == .loading)
    }
    
    public func setErrorDescriptionTrailing(offset: CGFloat) {
        errorView.setDescriptionTrailing(offset: offset)
    }

    private func configureForError(for fullName: String?) {
        tableBlockPlaneView.configure(for: .init(tableMainHeadingMlc: nil,
                                                 tableSecondaryHeadingMlc: nil,
                                                 items: [
                                                    DSTableItem.init(tableItemHorizontalMlc: .init(label: fullName ?? "",
                                                                                                   value: nil,
                                                                                                   valueImage: nil))
                                                 ]))
        tableBlockPlaneView.isHidden = false
        tickerAtm.isHidden = true
    }

    private func setLoading(isActive: Bool) {
        if isActive {
            loadingView.subview.play()
        } else {
            loadingView.subview.stop()
        }
        loadingView.isHidden = !isActive

        if loadingView.isHidden {
            containerView.transform = CGAffineTransform(translationX: .zero, y: self.frame.size.height * Constants.heightMultiplier)
            UIView.animate(
                withDuration: Constants.animationDuration,
                animations: {
                    self.containerView.transform = .identity
                    self.containerView.alpha = Constants.visibleContainerViewAlpha
                }
            )
        } else {
            containerView.alpha = .zero
        }
    }
    
    private func setupAccessibility() {
        containerView.isAccessibilityElement = true
        containerView.accessibilityTraits = .staticText
    }

    private func configureTicker(_ ticker: DSTickerAtom) {
        tickerAtm.configure(with: ticker) { [weak self] event in
            self?.eventsHandler?.handleEvent(event: event)
        }
    }
    
    private func setupErrorView() {
        containerView.addSubview(errorView)
        errorView.anchor(top: nil,
                         leading: leadingAnchor,
                         bottom: bottomAnchor,
                         trailing: trailingAnchor)
        errorView.isHidden = true
    }

    private func setupLoadingView() {
        addSubview(loadingView)
        loadingView.fillSuperview()

        loadingView.subview.loopMode = .loop
        loadingView.subview.backgroundBehavior = .pauseAndRestore
        loadingView.isHidden = true
    }

    public func didChangeFocus(isFocused: Bool) {
        if isFocused {
            tickerAtm.startAnimation()
        } else {
            tickerAtm.stopAnimation()
        }
    }
    
    public func willPresent() {
        tickerAtm.startAnimation()
    }
    
    public func didHide() {
        tickerAtm.stopAnimation()
    }
    
    // MARK: - VerifyDocumentViewProtocol
    public func verifyDocumentViewDidChangeLayout() {
        didChangeFocus(isFocused: false)
        didChangeFocus(isFocused: true)
    }
}

extension DSDocumentWithPhotoView {
    enum Constants {
        static let verticalPadding: CGFloat = 20
        static var customSpacing: CGFloat {
            switch UIScreen.main.bounds.width {
            case 320:
                return 16
            default:
                return 24
            }
        }
        static let bottomHeadingPaddding: CGFloat = 28
        static let verticalTickerPadding: CGFloat = 8
        static let planePadding: CGFloat = 16
        static let subTitleInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        static let loaderSize = CGSize(width: 80, height: 80)
        static let animationDuration: CGFloat = 0.3
        static let visibleContainerViewAlpha: CGFloat = 1.0
        static let heightMultiplier: CGFloat = 0.05
    }
}
