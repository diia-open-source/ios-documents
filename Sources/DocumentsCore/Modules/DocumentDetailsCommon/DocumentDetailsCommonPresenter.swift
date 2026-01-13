
import ReactiveKit
import DiiaMVPModule
import DiiaUIComponents

public protocol DocumentDetailsCommonAction: BasePresenter { }

public final class DocumentDetailsCommonPresenter: DocumentDetailsCommonAction {
    private unowned let view: DocumentDetailsCommonView
    private let viewModel: DocumentDetailsCommonViewModel
    private let insuranceTicker: DSTickerAtom?
    private let bag = DisposeBag()
    
    public init(view: DocumentDetailsCommonView,
                viewModel: DocumentDetailsCommonViewModel,
                insuranceTicker: DSTickerAtom?) {
        self.view = view
        self.viewModel = viewModel
        self.insuranceTicker = insuranceTicker
    }
    
    public func configureView() {
        view.setup(with: viewModel, insuranceTicker: insuranceTicker)
    }
}
