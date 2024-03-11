import XCTest
@testable import DiiaDocumentsCommonTypes

class DSDocumentDetailsPresenterTests: XCTestCase {
    private var view: DSDocumentDetailsMockView!
    private var viewModel: DocumentViewModel!
    
    override func tearDown() {
        view = nil
        viewModel = nil
        
        super.tearDown()
    }
    
    func test_configureView_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        
        // Act
        sut.configureView()
        
        // Assert
        XCTAssertTrue(view.isSetupCalled)
    }
    
    func test_get_codeViewModel_worksCorrect() {
        // Arrange
        let sut = makeSUT()
        let expectedValue = viewModel.codeViewModel
        
        // Act
        let value = sut.codeViewModel
        
        // Assert
        XCTAssertEqual(value?.docType?.docCode, expectedValue?.docType?.docCode)
    }
    
}

private extension DSDocumentDetailsPresenterTests {
    func makeSUT() -> DSDocumentDetailsPresenter {
        view = DSDocumentDetailsMockView()
        viewModel = DocumentViewModelStub()
        return .init(view: view,
                     viewModel: viewModel,
                     insuranceTicker: nil)
    }
}
