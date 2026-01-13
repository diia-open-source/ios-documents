
import UIKit
import DiiaMVPModule
import DiiaDocumentsCommonTypes

struct DocumentAttributesStub: DocumentAttributesProtocol {
    var docCode: DocTypeCode = "docType"
    
    var name: String = ""
    
    var stackName: String = ""
    
    var faqCategoryId: String = ""
    
    func verificationImage(verificationType: VerificationType) -> UIImage? {
        return nil
    }
    
    func warningModel() -> WarningModel? {
        return nil
    }
    
    var stackIconAppearance: DocumentStackIconAppearance = .black
    
    var isStaticDoc: Bool = false
    
    func isDocCodeSameAs(otherDocCode: DocTypeCode) -> Bool {
        return docCode == otherDocCode
    }
}
