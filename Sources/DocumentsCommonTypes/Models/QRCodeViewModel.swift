
import UIKit
import ReactiveKit
import DiiaCommonTypes
import DiiaUIComponents

public enum QRCodeStatus {
    case loading
    case error(errorViewModel: StubMessageViewModel)
    case offline
    case ready(link: String, barcode: String?)
    case expired
}

public protocol QRCodeHolder: NSObjectProtocol {
    func statusChanged(status: QRCodeStatus)
}

public class QRCodeViewModel {
    
    let docType: DocumentAttributesProtocol?
    let localization: LocalizationType
    let verificationType: VerificationType?
    
    weak var holder: QRCodeHolder?
    weak var timerLabel: UILabel?
    
    private let bag: DisposeBag = DisposeBag()
    private var timer: Timer?
    private var isCancelled: Bool = false
    
    private var loadingWorkItem: DispatchWorkItem?
    
    let flippingAction: Callback
    
    private var deprecationLength: TimeInterval = 180
    private var timerText: String = R.Strings.document_general_session_time.localized()
    
    var runTimer: Int = 0
    
    public init(document: DocumentModel,
                flippingAction: @escaping Callback,
                localization: LocalizationType = .ua,
                type: VerificationType? = nil) {
        
        self.docType = document.docType
        self.verificationType = type
        self.localization = localization
        self.flippingAction = flippingAction
        
        loadingWorkItem = DispatchWorkItem { [weak self, weak document] in
            guard let self = self, let document = document else { return }
            
            self.isCancelled = false
            self.holder?.statusChanged(status: .loading)
            
            document
                .sharingRequest()?
                .observe { [weak self] (event) in
                    guard let self = self, self.isCancelled == false else {
                        return
                    }
                    
                    switch event {
                    case .next(let object):
                        self.deprecationLength = TimeInterval(object.timerTime ?? 180)
                        self.holder?.statusChanged(status: .ready(link: object.link, barcode: object.barcode))
                        if self.docType?.isStaticDoc == false {
                            self.timerText = object.timerText ?? R.Strings.document_general_session_time.localized()
                            self.startTimer()
                        }
                    case .failed(let error):
                        switch error {
                        case .noInternet:
                            self.holder?.statusChanged(status: .offline)
                        case .wrongStatusCode(_, let code, _) where code < DocumentStatusCode.internalServerError.rawValue &&
                            code >= DocumentStatusCode.badRequest.rawValue:
                            self.holder?.statusChanged(status: .offline)
                        default:
                            self.holder?.statusChanged(
                                status: .error(
                                    errorViewModel: StubMessageViewModel(icon: "😔",
                                                                         title: self.localization == .ua ?
                                                                         R.Strings.document_general_registry_error.localized() :
                                                                            R.Strings.document_general_registry_error_en.localized(),
                                                                         descriptionText: self.localization == .ua ? R.Strings.document_general_registry_error_description.localized() :
                                                                            R.Strings.document_general_registry_error_description_en.localized(),
                                                                         repeatAction: { [weak self] in self?.loadCode() })
                                )
                            )
                        }
                    default:
                        break
                    }
                }
                .dispose(in: self.bag)
        }
    }
    
    @objc func updateTimer() {
        runTimer -= 1
        let minutes = (runTimer / 60) % 60
        let seconds = runTimer % 60
        
        let formatText = String(format: "\(timerText) %i:%02i \(localization == .en ? "min": "хв")", minutes, seconds)
        
        timerLabel?.text = formatText
        
        if runTimer == 0 {
            self.holder?.statusChanged(status: .expired)
            self.timer?.invalidate()
        }
    }
    
    private func startTimer() {
        cancelTimer()
        runTimer = Int(deprecationLength)
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        self.timer = timer
        timer.fire()
        RunLoop.main.add(timer, forMode: .common)
    }
    
    public func loadCode() {
        loadingWorkItem?.perform()
    }
    
    public func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    public func cancel() {
        isCancelled = true
        cancelTimer()
    }
}
