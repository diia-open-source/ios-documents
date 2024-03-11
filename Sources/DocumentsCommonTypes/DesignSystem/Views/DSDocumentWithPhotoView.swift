import UIKit
import DiiaUIComponents
import DiiaCommonTypes

public class DSDocumentWithPhotoView: BaseCodeView, FrontViewProtocol {
    
    private var docHeadingView = DSDocumentHeadingView()
    private var tableBlockTwoColumnsView = DSTableBlockTwoColumnsPlaneOrgView()
    private var tableBlockPlaneView = DSTableBlockPlaneOrgView()
    private var tickerAtm = FloatingTextLabel()
    private var boosterView = SmallButtonPanelMlcView()
    private var docBottomView = DSDocumentHeadingView()
    private var subtitleLabel = BoxView(subview: UILabel().withParameters(font: FontBook.smallHeadingFont))
        .withConstraints(insets: Constants.subTitleInset)
    private var verticalStack = UIStackView.create(views: [])
    
    private lazy var errorView = DocumentErrorView()
    
    public var contextMenuCallback: Callback? {
        didSet {
            docBottomView.configureAction(contextMenuCallback)
        }
    }
    
    public var tickerCallback: Callback?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        tickerAtm.animate()
    }
    
    public override func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        tableBlockTwoColumnsView.translatesAutoresizingMaskIntoConstraints = false
        tableBlockPlaneView.translatesAutoresizingMaskIntoConstraints = false
        docBottomView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(tableBlockTwoColumnsView)
        addSubview(tickerAtm)
        addSubview(docBottomView)
        addSubview(boosterView)

        verticalStack = UIStackView.create(.vertical,
                                           views: [docHeadingView, subtitleLabel],
                                           spacing: 0)

        addSubview(verticalStack)
        addSubview(tableBlockPlaneView)

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
        
        let topPlaneTableConstraint = tickerAtm.topAnchor.constraint(greaterThanOrEqualTo: tableBlockPlaneView.bottomAnchor,
                                                                     constant: Constants.verticalTickerPadding)
        topPlaneTableConstraint.priority = .defaultHigh
        topPlaneTableConstraint.isActive = true

        let topTwoColumnTableConstraint = tickerAtm.topAnchor.constraint(greaterThanOrEqualTo: tableBlockTwoColumnsView.bottomAnchor,
                                                                         constant: Constants.verticalTickerPadding)
        topTwoColumnTableConstraint.priority = .defaultHigh
        topTwoColumnTableConstraint.isActive = true

        tickerAtm.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        tickerAtm.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true

        docBottomView.topAnchor.constraint(greaterThanOrEqualTo: tickerAtm.bottomAnchor,
                                           constant: Constants.verticalTickerPadding).isActive = true

        boosterView.anchor(leading: leadingAnchor,
                            bottom: tickerAtm.topAnchor,
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
        setupErrorView()
    }
    
    /// - Parameters:
    ///   - modelData: The model to be processed. Can be `nil` if not applicable.
    ///   - shouldStopAfterErrorConfigured: A boolean flag indicating whether the configuring nested views should stop immediately if an `modelData.errorViewModel` exists and configured.
    ///   - insuranceTicker: An optional specific insuranse ticker for handling events in `FloatingTextLabel`. Defaults to `nil`.
    public func configure(for modelData: DocumentViewModel?,
                          shouldStopAfterErrorConfigured: Bool = true,
                          insuranceTicker: DSTickerAtom? = nil) {

        guard let data = modelData?.model else { return }
        
        guard let frontCard = data.currentLocalization() == .ua ? data.frontCard?.UA : data.frontCard?.EN else { return }
        
        if let docHeading = frontCard.first(where: {$0.docHeadingOrg != nil})?.docHeadingOrg {
            docHeadingView.configure(model: docHeading)
            docHeadingView.isHidden = false
        }
        if let errorVM = modelData?.errorViewModel {
            errorView.isHidden = false
            errorView.configure(with: errorVM)
            configureForError(for: modelData?.nameRaw.replacingOccurrences(of: " ", with: "\n"))
            if shouldStopAfterErrorConfigured { return }
        }
        
        let imagesContent = modelData?.images
        
        if let tableBlockTwoColumnsPlane = frontCard.first(where: {$0.tableBlockTwoColumnsPlaneOrg != nil})?.tableBlockTwoColumnsPlaneOrg {
            tableBlockTwoColumnsView.configure(models: tableBlockTwoColumnsPlane, imagesContent: imagesContent ?? [:])
            tableBlockTwoColumnsView.isHidden = false
        }
        if let ticker = frontCard.first(where: {$0.tickerAtm != nil})?.tickerAtm {
            configureTicker(ticker)
        } else if let insuranceTicker = insuranceTicker {
            configureTicker(insuranceTicker)
        } else {
            tickerAtm.withHeight(0)
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
            tableBlockPlaneView.configure(for: tableBlockOrg)
            tableBlockPlaneView.isHidden = false
        }
        if let boosterMlc = frontCard.first(where: {$0.smallEmojiPanelMlc != nil})?.smallEmojiPanelMlc {
            boosterView.configure(for: boosterMlc)
            boosterView.isHidden = false
        }
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
        tickerAtm.withHeight(0)
    }
    
    fileprivate func configureTicker(_ ticker: DSTickerAtom) {
        tickerAtm.configure(model: ticker)
        if ticker.action != nil {
            let insuranceTap = UITapGestureRecognizer.init(target: self, action: #selector(tickerAction(_:)))
            tickerAtm.isUserInteractionEnabled = true
            tickerAtm.addGestureRecognizer(insuranceTap)
        }
    }
    
    fileprivate func setupErrorView() {
        addSubview(errorView)
        errorView.anchor(top: nil,
                         leading: leadingAnchor,
                         bottom: bottomAnchor,
                         trailing: trailingAnchor)
        errorView.isHidden = true
    }
    
    public func didChangeFocus(isFocused: Bool) {
        if isFocused {
            tickerAtm.animate()
        } else {
            tickerAtm.stopAnimation()
        }
    }
    
    public func willPresent() {
        tickerAtm.animate()
    }
    
    public func didHide() {
        tickerAtm.stopAnimation()
    }
    
    @objc private func tickerAction(_ sender: UIButton) {
        tickerCallback?()
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
    }
}
