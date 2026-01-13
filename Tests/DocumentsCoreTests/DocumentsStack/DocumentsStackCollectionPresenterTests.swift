
import XCTest
import DiiaDocumentsCommonTypes
@testable import DiiaDocumentsCore

final class DocumentsStackCollectionPresenterTests: XCTestCase {
    private var view: DocumentsCollectionMockView!
    private var documentAttributes: DocumentAttributesStub!
    private var holder: DocumentCollectionHolderMock!
    private var documentsProvider: DocumentsProviderMock!
    
    override func tearDown() {
        view = nil
        documentAttributes = nil
        holder = nil
        documentsProvider = nil
        
        super.tearDown()
    }
    
    func test_configureView_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        
        // Assert
        XCTAssertTrue(view.isUpdateDocumentsCalled)
    }
    
    func test_viewDidAppear_worksCorrect() {
        // Arrange
        var receivedDocTypeCode: String?
        let stackCollectionAppearsAction: OnDocumentsStackCollectionAppears = { code in
            receivedDocTypeCode = code
        }
        let sut = makeSUT(stackCollectionAppearsAction: stackCollectionAppearsAction)
        
        // Act
        sut.viewDidAppear()
        
        // Assert
        XCTAssertEqual(receivedDocTypeCode, documentAttributes.docCode)
    }
    
    func test_documentsWasUpdated_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.documentsWasUpdated()
        
        // Assert
        XCTAssertTrue(view.isUpdateDocumentsCalled)
        XCTAssertTrue(view.isCloseModuleCalled)
    }
    
    func test_numberOfItems_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        let expectedValue: Int = 1
        
        // Act
        let actualValue = sut.numberOfItems()
        
        // Assert
        XCTAssertEqual(actualValue, expectedValue)
    }
    
    func test_itemAtIndex_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        let item = sut.itemAtIndex(index: .zero)
        
        // Assert
        XCTAssertNotNil(item)
        XCTAssertTrue(item?.getValue() is DocumentModelMock)
    }

    func test_selectItem_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.selectItem(index: .zero)
        
        // Assert
        XCTAssert(view.isFlipCurrentItemCalled)
    }
    
    func test_updateBackgroundImage_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.updateBackgroundImage(image: UIImage())
        
        // Assert
        XCTAssertTrue(holder.isUpdateBackgroundImageCalled)
    }
    
}

private extension DocumentsStackCollectionPresenterTests {
    func makeSUT(stackCollectionAppearsAction: OnDocumentsStackCollectionAppears? = nil) -> DocumentsStackCollectionPresenter {
        view = DocumentsCollectionMockView()
        documentAttributes = DocumentAttributesStub()
        holder = DocumentCollectionHolderMock()
        documentsProvider = DocumentsProviderMock(documents: [DocumentModelMock()])
        return .init(view: view,
                     docType: documentAttributes,
                     holder: holder,
                     documentsProvider: documentsProvider,
                     onDocsStackCollectionAppearsAction: stackCollectionAppearsAction)
    }
}
