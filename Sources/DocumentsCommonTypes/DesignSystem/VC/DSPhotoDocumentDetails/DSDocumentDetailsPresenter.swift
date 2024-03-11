import UIKit
import DiiaMVPModule
import DiiaUIComponents

protocol DSDocumentDetailsAction: BasePresenter {
    var codeViewModel: QRCodeViewModel? { get }
}

final class DSDocumentDetailsPresenter {
    private unowned let view: DSDocumentDetailsView
    private let viewModel: DocumentViewModel
    private let insuranceTicker: DSTickerAtom?
    
    init(view: DSDocumentDetailsView,
         viewModel: DocumentViewModel,
         insuranceTicker: DSTickerAtom?) {
        self.view = view
        self.viewModel = viewModel
        self.insuranceTicker = insuranceTicker
    }
    
    func configureView() {
        view.setup(with: viewModel, insuranceTicker: insuranceTicker)
    }
}
    
extension DSDocumentDetailsPresenter: DSDocumentDetailsAction {
    var codeViewModel: QRCodeViewModel? {
        return viewModel.codeViewModel
    }
}
