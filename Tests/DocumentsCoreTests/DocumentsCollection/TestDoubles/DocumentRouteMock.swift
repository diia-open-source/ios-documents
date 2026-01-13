
import Foundation
import DiiaMVPModule
import DiiaCommonTypes

final class DocumentRouteMock: RouterProtocol {
    private(set) var isRouteCalled = false
    
    func route(in view: BaseView) {
        isRouteCalled.toggle()
    }
}
