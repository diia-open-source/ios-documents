import UIKit
import DiiaMVPModule
import DiiaCommonTypes
import DiiaUIComponents

protocol DSDocumentDetailsView: BaseView {
    func setup(with viewModel: DocumentViewModel,
               insuranceTicker: DSTickerAtom?)
}

final class DSDocumentDetailsViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let mainStack = UIStackView.create(views: [], spacing: Constants.defaultSpacing)
    
    private let docHeadingView = DSDocumentHeadingView()
    private let tickerAtm = FloatingTextLabel()
    private let tableTwoBlockOrg = DSTableBlockTwoColumnsOrgView()
    private let tableBlocksOrg = DSTableBlocksView()
    private var codeView = BoxView(subview: QRCodeBarcodeView()).withConstraints(insets: Constants.codePadding)
    ///   - screenBrightnessService: A service responsible for managing screen brightness.
    var screenBrightnessService: ScreenBrightnessServiceProtocol?
    
    var presenter: DSDocumentDetailsAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presenter.configureView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tickerAtm.reset()
        screenBrightnessService?.resetBrightness()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tickerAtm.animate()
        presenter.codeViewModel?.loadCode()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tickerAtm.animate()
    }
    
    private func setupViews() {
        view.backgroundColor = Constants.backgroundColor
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        scrollView.addSubview(mainStack)
        mainStack.fillSuperview(padding: Constants.stackPadding)
        mainStack.withWidth(view.frame.width)
        let boxView = BoxView(subview: docHeadingView).withConstraints(insets: Constants.docHeadingInset)
        mainStack.addArrangedSubview(boxView)
        mainStack.addArrangedSubview(tickerAtm)
        mainStack.addArrangedSubview(tableTwoBlockOrg)
        mainStack.addArrangedSubview(tableBlocksOrg)
        mainStack.addArrangedSubview(codeView)
        
        mainStack.setCustomSpacing(Constants.customStackSpacing,
                                   after: docHeadingView)
        mainStack.setCustomSpacing(Constants.customStackSpacing,
                                   after: tickerAtm)
        
        codeView.heightAnchor.constraint(equalTo: mainStack.widthAnchor,
                                         multiplier: Constants.codeViewHeightProportion).isActive = true
    }
}

extension DSDocumentDetailsViewController: DSDocumentDetailsView {
    
    func setup(with viewModel: DocumentViewModel,
               insuranceTicker: DSTickerAtom?) {
        guard let fullInfo = viewModel.model?.fullInfo else { return }
        if let docHeading = fullInfo.first(where: {$0.docHeadingOrg != nil})?.docHeadingOrg {
            docHeadingView.configure(model: docHeading)
        }
        if let ticker = fullInfo.first(where: {$0.tickerAtm != nil})?.tickerAtm {
            tickerAtm.configure(model: ticker)
        } else if let insuranceTicker = insuranceTicker {
            tickerAtm.configure(model: insuranceTicker)
        } else {
            tickerAtm.withHeight(0)
        }
        
        if let tableBlockTwoColumnsOrg = fullInfo.first(where: {$0.tableBlockTwoColumnsOrg != nil})?.tableBlockTwoColumnsOrg {
            tableTwoBlockOrg.configure(models: tableBlockTwoColumnsOrg,
                                       imagesContent: viewModel.images)
        } else {
            tableTwoBlockOrg.isHidden = true
        }
        
        let tableBlockOrg = fullInfo.filter({$0.tableBlockOrg != nil}).compactMap({$0.tableBlockOrg})
        if !tableBlockOrg.isEmpty {
            tableBlocksOrg.configure(model: tableBlockOrg)
        }
        if let codeModel = presenter.codeViewModel {
            codeView.subview.configure(viewModel: codeModel)
        }
    }
    
}

extension DSDocumentDetailsViewController {
    enum Constants {
        static let defaultSpacing: CGFloat = 16
        static let customStackSpacing: CGFloat = 24
        static let backgroundColor: UIColor = UIColor("#f1f6f6")
        static let docHeadingInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        static let stackPadding = UIEdgeInsets.init(top: 28, left: 0, bottom: 32, right: 0)
        static let codePadding = UIEdgeInsets.init(top: 0, left: 24, bottom: 0, right: 24)
        static let codeViewHeightProportion: CGFloat = 1.25
    }
}
