
import XCTest
import ReactiveKit
import DiiaDocumentsCommonTypes
@testable import DiiaDocumentsCore

class DocumentsCollectionPresenterTests: XCTestCase {
    private var view: DocumentsCollectionMockView!
    private var holder: DocumentCollectionHolderMock!
    private var documentsProvider: DocumentsProviderMock!
    private var documentsLoader: DocumentsLoaderMock!
    private var documentRoute: DocumentRouteMock!
    private var pushNotificationsSharingSubject: PassthroughSubject<Void, Never>!
    
    override func tearDown() {
        view = nil
        holder = nil
        documentsProvider = nil
        documentsLoader = nil
        documentRoute = nil
        pushNotificationsSharingSubject = nil
        
        super.tearDown()
    }
    
    func test_configureView_worksCorrect() {
        // Arrange
        var sut: DocumentsCollectionPresenter? = makeSUT()
        
        // Act
        sut?.configureView()
        
        // Assert
        XCTAssertTrue(documentsLoader.isAddListenerCalled)
        XCTAssertTrue(view.isUpdateDocumentsCalled)
        
        sut = nil
        XCTAssertTrue(documentsLoader.isRemoveListenerCalled)
    }
    
    func test_viewDidAppear_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.viewDidAppear()
        
        // Assert
        XCTAssertTrue(documentsLoader.isUpdateIfNeededCalled)
    }
    
    func test_check_reachability_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.checkReachability()
        
        // Assert
        XCTAssertTrue(view.isSetStatusTextCalled)
    }
    
    func test_documentsWasUpdated_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.documentsWasUpdated()
        
        // Assert
        XCTAssertTrue(view.isUpdateDocumentsCalled)
    }
    
    func test_secondaryDocumentsWasUpdated_worksCorrect() {
        // Arrange
        let document = DocumentModelMock()
        let sut = makeSUT(documents: [document])
        
        // Act
        sut.configureView()
        sut.secondaryDocumentsWasUpdated()
        
        // Assert
        XCTAssertTrue(view.isUpdateDocumentsCalled)
        XCTAssertTrue(document.isUpdateIfNeeded)
    }
    
    func test_numberOfItems_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        let expectedValue: Int = 2
        
        // Act
        sut.configureView()
        let actualValue = sut.numberOfItems()
        
        // Assert
        XCTAssertTrue(view.isUpdateDocumentsCalled)
        XCTAssertEqual(actualValue, expectedValue)
    }
    
    func test_itemAtIndex_successfully() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        let item = sut.itemAtIndex(index: .zero)
        
        // Assert
        XCTAssertTrue(view.isUpdateDocumentsCalled)
        XCTAssertNotNil(item)
        XCTAssertTrue(item?.getValue() is DocumentModelMock)
    }
    
    func test_itemAtIndex_unsuccessfully() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        let item = sut.itemAtIndex(index: 2)
        
        // Assert
        XCTAssertTrue(view.isUpdateDocumentsCalled)
        XCTAssertNil(item)
    }

    func test_selectItem_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.selectItem(index: .zero)
        
        // Assert
        XCTAssert(view.isFlipCurrentItemCalled)
    }
    
    func test_processAction_successfully() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        sut.processAction(action: "docType")
        
        // Assert
        XCTAssertTrue(view.isScrollCalled)
    }
    
    func test_processAction_unsuccessfully() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        sut.processAction(action: "")
        
        // Assert
        XCTAssertFalse(view.isScrollCalled)
    }
    
    func test_updateBackgroundImage_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.updateBackgroundImage(image: UIImage())
        
        // Assert
        XCTAssertTrue(holder.isUpdateBackgroundImageCalled)
    }
    
    func test_stackClickedMultiple_worksCorrect() {
        // Arrange
        let sut = makeSUT(documents: [DocumentModelMock(), DocumentModelMock()])
        
        // Act
        sut.configureView()
        sut.stackClicked(at: .zero)
        
        // Assert
        XCTAssertTrue(view.isUpdateDocumentsCalled)
        XCTAssertTrue(documentRoute.isRouteCalled)
    }
    
    func test_stackClickedSingle_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        sut.stackClicked(at: .zero)
        
        // Assert
        XCTAssertTrue(view.isUpdateDocumentsCalled)
    }
    
    func test_onSharingRequestReceived_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        pushNotificationsSharingSubject.receive()
        
        // Assert
        XCTAssertTrue(view.isOnSharingRequestReceived)
    }
    
    func test_scrollDocIfNeeded_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.processAction(action: "docType")
        sut.documentsWasUpdated()
        
        // Assert
        XCTAssertTrue(view.isScrollCalled)
    }
    
}

private extension DocumentsCollectionPresenterTests {
    func makeSUT(documents: [DocumentModel] = [DocumentModelMock()]) -> DocumentsCollectionPresenter {
        view = DocumentsCollectionMockView()
        holder = DocumentCollectionHolderMock()
        documentsProvider = DocumentsProviderMock(documents: documents)
        documentsLoader = DocumentsLoaderMock()
        documentRoute = DocumentRouteMock()
        pushNotificationsSharingSubject = .init()
        return .init(context: DocumentsCollectionContextStub(documentsLoader: documentsLoader,
                                                             docProvider: documentsProvider,
                                                             documentsStackRouterCreate: { _ in self.documentRoute },
                                                             pushNotificationsSharingSubject: pushNotificationsSharingSubject),
                     view: view,
                     holder: holder)
    }
}
