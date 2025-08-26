
import XCTest
import DiiaDocumentsCommonTypes
@testable import DiiaDocumentsCore

class DocumentStackActionsFabricTests: XCTestCase {
    
    func test_getAction_singleDocument() {
        // Arrange
        let sut = DocumentStackActionsFabric()
        let document = DocumentModelMock(actions: [[.init(title: nil,
                                                          iconName: nil,
                                                          callback: {}),
                                                    .init(title: nil,
                                                          iconName: nil,
                                                          callback: {})]])
        let view = BaseMockView()
        let flipper = FlipperStub()
        let dataType: MultiDataType<DocumentModel> = .single(document)
        
        // Act
        let callback = sut.getAction(for: dataType, view: view, flipper: flipper)
        
        // Assert
        XCTAssertNotNil(callback)
    }
    func test_getAction_multipleDocuments() {
        // Arrange
        let sut = DocumentStackActionsFabric()
        let view = BaseMockView()
        let flipper = FlipperStub()
        let dataType: MultiDataType<DocumentModel> = .multiple([DocumentModelMock(), DocumentModelMock()])
        
        // Act
        let callback = sut.getAction(for: dataType, view: view, flipper: flipper)
        
        // Assert
        XCTAssertNil(callback)
    }
    
    func test_getAction_noActions() {
        // Arrange
        let sut = DocumentStackActionsFabric()
        let view = BaseMockView()
        let flipper = FlipperStub()
        let dataType: MultiDataType<DocumentModel> = .single(DocumentModelMock())
        
        // Act
        let callback = sut.getAction(for: dataType, view: view, flipper: flipper)
        
        // Assert
        XCTAssertNil(callback)
    }
    
    func test_getAction_callback() {
        // Arrange
        let sut = DocumentStackActionsFabric()
        let view = BaseMockView()
        let flipper = FlipperStub()
        let dataType: MultiDataType<DocumentModel> = .single(DocumentModelMock(actions: [[.init(title: "", iconName: "", callback: {})]]))
        
        // Act
        let callback = sut.getAction(for: dataType, view: view, flipper: flipper)
        callback?()
        
        // Assert
        XCTAssertTrue(view.isDocActionSheetModuleCalled)
    }
}
