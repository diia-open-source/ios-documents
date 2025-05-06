
import UIKit
import DiiaMVPModule
import DiiaUIComponents
import DiiaDocumentsCommonTypes

public class DocumentDetailsCommonModule: BaseModule {
    
    let view: DocumentDetailsCommonViewController
    let presenter: DocumentDetailsCommonPresenter
    
    public init(with viewModel: DocumentDetailsCommonViewModel,
                insuranceTicker: DSTickerAtom? = nil) {
        view = DocumentDetailsCommonViewController()
        view.screenBrightnessService = DocumentsCommonConfiguration.shared.screenBrightnessService
        
        presenter = DocumentDetailsCommonPresenter(view: view,
                                                   viewModel: viewModel,
                                                   insuranceTicker: insuranceTicker)
        view.presenter = presenter
    }
    
    public func viewController() -> UIViewController {
        let vc = PresentedController(viewController: view)
        return vc
    }
}
