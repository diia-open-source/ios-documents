import UIKit
import DiiaMVPModule
import DiiaUIComponents

public class DSDocumentDetailsModule: BaseModule {
    
    private let view: DSDocumentDetailsViewController
    private let presenter: DSDocumentDetailsPresenter
    
    /// - Parameters:
    ///   - viewModel: The viewModel to be processed.
    ///   - insuranceTicker: An optional specific insuranse ticker for handling events in `FloatingTextLabel`. Defaults to `nil`.
    public init(with viewModel: DocumentViewModel,
                insuranceTicker: DSTickerAtom? = nil) {
        view = DSDocumentDetailsViewController()
        view.screenBrightnessService = DocumentsCommonConfiguration.shared.screenBrightnessService
        
        presenter = DSDocumentDetailsPresenter(view: view,
                                               viewModel: viewModel,
                                               insuranceTicker: insuranceTicker)
        view.presenter = presenter
    }

    public func viewController() -> UIViewController {
        let vc = PresentedController(viewController: view)
        return vc
    }
}
