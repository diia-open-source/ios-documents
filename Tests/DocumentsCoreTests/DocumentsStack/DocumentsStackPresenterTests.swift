
import XCTest
import DiiaDocumentsCommonTypes
@testable import DiiaDocumentsCore

class DocumentsStackPresenterTests: XCTestCase {
    private var view: DocumentsStackMockView!
    private var documentAttributes: DocumentAttributesStub!
    private var documentsProvider: DocumentsProviderMock!
    
    override func tearDown() {
        view = nil
        documentAttributes = nil
        documentsProvider = nil
        
        super.tearDown()
    }
    
    func test_configureView_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        
        // Assert
        XCTAssertTrue(view.isSetupChildCalled)
        XCTAssertTrue(view.isSetupTitleCalled)
    }
    
    func test_updateBackgroundImage_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.updateBackgroundImage(image: UIImage())
        
        // Assert
        XCTAssertTrue(view.isSetBackgroundImageCalled)
    }
    
}

private extension DocumentsStackPresenterTests {
    func makeSUT() -> DocumentsStackPresenter {
        view = DocumentsStackMockView()
        documentAttributes = DocumentAttributesStub()
        documentsProvider = DocumentsProviderMock(documents: [DocumentModelMock()])
        return .init(view: view,
                     docType: documentAttributes,
                     docProvider: documentsProvider,
                     onDocsStackCollectionAppearsAction: nil)
    }
}
