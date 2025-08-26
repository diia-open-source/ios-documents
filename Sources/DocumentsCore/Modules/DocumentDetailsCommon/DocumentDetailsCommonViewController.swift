
import UIKit
import DiiaMVPModule
import DiiaCommonTypes
import DiiaUIComponents
import DiiaDocumentsCommonTypes

public protocol DocumentDetailsCommonView: BaseView {
    func setup(with viewModel: DocumentDetailsCommonViewModel,
               insuranceTicker: DSTickerAtom?)
}

public class DocumentDetailsCommonViewController: UIViewController {
    
    public var screenBrightnessService: ScreenBrightnessServiceProtocol?
    public var presenter: DocumentDetailsCommonAction!
    
    private var constructorView: ConstructorModalView? { view as? ConstructorModalView }
    
    // MARK: - Properties

    private var viewFabric = DSViewFabric()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Constants.backgroundColor
        presenter.configureView()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        screenBrightnessService?.resetBrightness()
    }
    
    public override func loadView() {
        super.loadView()
        
        let view = ConstructorModalView(frame: UIScreen.main.bounds)
        view.bodyScrollView.bottomSeparatorType = .none
        view.bottomGroupBottomConstraint = super.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        self.view = view
    }
}

extension DocumentDetailsCommonViewController: DocumentDetailsCommonView {
    
    public func setup(with viewModel: DocumentDetailsCommonViewModel,
                      insuranceTicker: DSTickerAtom?) {
        var fullInfo = viewModel.model?.fullInfo ?? []
        
        if let ticker = insuranceTicker {
            let tickerAnyCodable = AnyCodable.dictionary([
                Constants.tickerAtmKey: AnyCodable.fromEncodable(encodable: ticker)
            ])
            fullInfo.insert(tickerAnyCodable, at: 1)
        }
        
        setupFabric(images: viewModel.images)
        let model = DSConstructorModel(topGroup: [], body: fullInfo)
        
        let eventHandler: (ConstructorItemEvent) -> Void = { [weak viewModel] event in
            viewModel?.eventHandler?.handleEvent(event: event)
        }

        let bodyViews = viewFabric.bodyViews(for: model,
                                             eventHandler: eventHandler)
        self.constructorView?.setupTopGroup(views: [])
        self.constructorView?.setupBody(views: bodyViews, withCloseButton: false)
    }
    
    private func setupFabric(images: [DSDocumentContentData: UIImage]) {
        let twoColumnBuilder = DSTableBlockTwoColumnsOrgBuilder(imagesContent: images)
        viewFabric.setBuilder(twoColumnBuilder)
        let tickerBuilder = DSTickerAtmBuilder(padding: Constants.tickerAtmPadding)
        viewFabric.setBuilder(tickerBuilder)
        let chipGroupBuilder = DSChipsBlackOrgBuilder(isActive: false)
        viewFabric.setBuilder(chipGroupBuilder)
    }
}

extension DocumentDetailsCommonViewController {
    enum Constants {
        static let backgroundColor: UIColor = UIColor("#f1f6f6")
        static let tickerAtmPadding = UIEdgeInsets(top: 24, left: .zero, bottom: .zero, right: .zero)
        static let tickerAtmKey = "tickerAtm"
    }
}
