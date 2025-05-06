
import Foundation
import ReactiveKit
import DiiaUIComponents
import DiiaNetwork
import DiiaDocumentsCommonTypes

public class DocumentDetailsEventHandler: NSObject, DSConsructorEventHandler {
    
    private let verificationRequest: (() -> Signal<ShareVerificationCodesModel, NetworkError>)?
    private let localisation: LocalizationType
    private var verificationCodesViewModel: DSVerificationCodesViewModel?
    private let disposeBag = DisposeBag()
    
    public init(verificationRequest: (() -> Signal<ShareVerificationCodesModel, NetworkError>)?,
                localisation: LocalizationType = .ua,
                verificationCodesViewModel: DSVerificationCodesViewModel? = nil) {
        self.verificationRequest = verificationRequest
        self.localisation = localisation
        self.verificationCodesViewModel = verificationCodesViewModel
    }
    
    public func handleEvent(event: ConstructorItemEvent) {
        switch event {
        case .action(let parameters):
            handleAction(with: parameters)
        case .onComponentConfigured(let eventType):
            switch eventType {
            case .verificationOrg(let viewModel):
                self.verificationCodesViewModel = viewModel
                self.getVerificationCodes()
            default: break
            }
        default: break
        }
    }
    
    private func handleAction(with parameters: DSActionParameter) {
        switch parameters.type {
        case Constants.refreshCode:
            getVerificationCodes()
        default: break
        }
    }
    
    private func getVerificationCodes() {
        guard let verificationRequest = verificationRequest else { return }
        verificationRequest()
            .observe { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .next(let data):
                    guard let verificationCodesOrg = data.verificationCodesOrg else {
                        self.configureErrorState()
                        return
                    }
                    let verificationModel = localisation == .ua ? verificationCodesOrg.UA : verificationCodesOrg.EN
                    if let verificationModel = verificationModel {
                        self.verificationCodesViewModel?.update(
                            componentId: verificationCodesOrg.componentId,
                            model: verificationModel,
                            repeatAction: { [weak self] in
                                self?.getVerificationCodes()
                            })
                    }
                case .failed:
                    self.configureErrorState()
                default:
                    break
                }
            }
            .dispose(in: disposeBag)
    }
    
    private func configureErrorState() {
        verificationCodesViewModel?.update(
            componentId: .empty,
            model: DSVerificationCodesData(stubMessageMlc: Constants.verificationErrorStub),
            repeatAction: { [weak self] in
                self?.getVerificationCodes()
            })
    }
}

private extension DocumentDetailsEventHandler {
    enum Constants {
        static let refreshCode = "refresh"
        static let verificationErrorStub = DSStubMessageMlc(icon: "☝️",
                                                            title: R.Strings.document_general_error_codes_not_loaded.localized(),
                                                            description: nil,
                                                            componentId: nil,
                                                            parameters: nil,
                                                            btnStrokeAdditionalAtm: DSButtonModel(label: R.Strings.document_general_retry.localized(),
                                                                                                  state: .enabled,
                                                                                                  action: .init(type: Self.refreshCode)))
    }
}
