
import UIKit
import DiiaCommonTypes
import DiiaUIComponents
import DiiaDocumentsCommonTypes

final class AddNewDocumentView: UIView, FrontViewProtocol {
    
    // MARK: - Outlets
    @IBOutlet weak private var addDocumentView: UIView!
    @IBOutlet weak private var addDocumentLabel: UILabel!
    @IBOutlet weak private var addDocumentButton: UIButton!
    @IBOutlet weak private var changeOrderView: UIView!
    @IBOutlet weak private var changeOrderLabel: UILabel!
    @IBOutlet weak private var changeOrderButton: UIButton!
    
    // MARK: - Properties
    var contextMenuCallback: Callback?
    private var addDocumentCallback: Callback?
    private var changeOrderCallback: Callback?

    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupStaticViews()
        setupFonts()
    }
    
    // MARK: - Setup
    private func setupStaticViews() {
        addDocumentView.backgroundColor = Constants.backgroundColor
        addDocumentView.layer.cornerRadius = Constants.cornerRadius
        changeOrderView.backgroundColor = Constants.backgroundColor
        changeOrderView.layer.cornerRadius = Constants.cornerRadius
        
        addDocumentLabel.text = R.Strings.document_general_add_document.localized()
        changeOrderLabel.text = R.Strings.document_general_change_documents_order.localized()
    }
    
    private func setupFonts() {
        addDocumentLabel.font = FontBook.smallHeadingFont
        changeOrderLabel.font = FontBook.smallHeadingFont
    }
    
    // MARK: - Public
    func configure(addDocumentCallback: @escaping Callback, changeOrderCallback: @escaping Callback) {
        self.addDocumentCallback = addDocumentCallback
        self.changeOrderCallback = changeOrderCallback
    }
    
    // MARK: - Private Methods
    @IBAction private func addDocumentButtonTapped(_ sender: UIButton) {
        addDocumentCallback?()
    }
    
    @IBAction private func changeOrderButtonTapped(_ sender: UIButton) {
        changeOrderCallback?()
    }
}

// MARK: - Constants
extension AddNewDocumentView {
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let backgroundColor: UIColor = .white.withAlphaComponent(0.4)
    }
}
