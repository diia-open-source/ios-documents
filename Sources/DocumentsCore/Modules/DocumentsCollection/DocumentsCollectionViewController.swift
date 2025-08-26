
import UIKit
import DiiaMVPModule
import DiiaUIComponents
import DiiaCommonTypes

protocol DocumentsCollectionView: BaseView {
    func updateDocuments()
    func setStatusText(statusText: String?)
    func scroll(to indexPath: IndexPath, animated: Bool)
    func onSharingRequestReceived()
    func flipCurrentItem()
    func isVisible() -> Bool
}

final class DocumentsCollectionViewController: UIViewController, Storyboarded {

	// MARK: - Properties
	var presenter: DocumentsCollectionAction!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var scrollingPageControl: ScrollingPageControl!
    @IBOutlet weak private var statusTextView: FloatingTextLabel!
    @IBOutlet weak private var dateLabelTopFromDocumentCenterConstraint: NSLayoutConstraint!

    private var lastIndexPath: IndexPath?
    private var visibleIndexPath: IndexPath?
    private var needUpdatesUI: Bool = false
    private var needLateUpdatesUI: Bool = false
    var actionFabric: DocumentActionsFabricProtocol?
    
    private var bgColorHex: String!
    private var cardColorHex: String!
    
    private var pagingData: (current: Int, total: Int) = (0, 0) {
        didSet {
            scrollingPageControl.isHidden = pagingData.total < Constants.minAmountToShowPages
            
            scrollingPageControl.pages = pagingData.total
            scrollingPageControl.selectedPage = pagingData.current
            
            scrollingPageControl.maxDots = Constants.maxDots(for: pagingData.total)
            scrollingPageControl.centerDots = Constants.centerDots(for: pagingData.total)
            scrollingPageControl.dotSize = Constants.dotSize
        }
    }
    
	// MARK: - Lifecycle
	override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(DocumentCollectionCell.self, forCellWithReuseIdentifier: DocumentCollectionCell.reuseID)
        let layout = ZoomAndSnapFlowLayout(
            itemSize: .init(width: DocumentsLayoutProvider.cardWidth,
                            height: DocumentsLayoutProvider.cardHeight),
            minimumSpacing: DocumentsLayoutProvider.cardInteritemSpacing
        )
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.decelerationRate = .fast
        
        scrollingPageControl.dotColor = Constants.scrollingDotColor
        scrollingPageControl.selectedColor = .white
        scrollingPageControl.accessibilityActionsDelegate = self
        
        setupLongGestureRecognizerOnCollection()
        dateLabelTopFromDocumentCenterConstraint.constant = DocumentsLayoutProvider.cardHeight/2 + Constants.pageInset
        setupAccessibility()
        
        presenter.configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        visibleIndexPath = lastIndexPath
        if needUpdatesUI {
            updateUI(animated: false)
        } else {
            needLateUpdatesUI = true
        }
        
        if let visibleIndexPath, let cell = collectionView.cellForItem(at: visibleIndexPath), !needUpdatesUI {
            UIAccessibility.post(notification: .layoutChanged, argument: cell)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
        presenter.checkReachability()
        if needLateUpdatesUI, let visible = visibleIndexPath {
            (collectionView.cellForItem(at: visible) as? DocumentCollectionCell)?.changeFocusing(isFocused: true)
            needLateUpdatesUI = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        collectionView.visibleCells.forEach { cell in
            (cell as? DocumentCollectionCell)?.shouldHide()
            (cell as? DocumentCollectionCell)?.changeFocusing(isFocused: false)
        }
        if let indexPath = lastIndexPath {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            setVisibleItem(indexPath: indexPath)
        }
    }
    
    // MARK: - Helping methods
    private func setVisibleItem(indexPath: IndexPath?, animated: Bool = true) {
        visibleIndexPath = indexPath
        collectionView.indexPathsForVisibleItems.forEach { [weak self] indexPath in
            guard let self else { return }
            let isVisible = indexPath == self.visibleIndexPath || self.visibleIndexPath == nil
            let cell = self.collectionView.cellForItem(at: indexPath) as? DocumentCollectionCell
            
            if isVisible {
                UIAccessibility.post(notification: .layoutChanged, argument: cell)
            }
            
            guard (self.pagingData.total - 1) != indexPath.row || !self.presenter.haveAdditionalCard else {
                cell?.setContentHidden(isHidden: false, animated: false)
                return
            }
            cell?.setContentHidden(isHidden: !isVisible, animated: animated)
        }
    }
    
    private func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = Constants.longPressDuration
        longPressedGesture.delaysTouchesBegan = true
        collectionView?.addGestureRecognizer(longPressedGesture)
    }

    @objc private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }

        let point = gestureRecognizer.location(in: collectionView)

        if let indexPath = collectionView?.indexPathForItem(at: point) {
            presenter.stackClicked(at: indexPath.item)
        }
    }
    
    // MARK: - Accessibility
    override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        // Handling scrolling in VoiceOver mode
        if direction == .right || direction == .left {
            let proposedContentOffset: CGPoint
            switch direction {
            case .right:
                proposedContentOffset = .init(x: collectionView.contentOffset.x - collectionView.frame.size.width/2, y: .zero)
            case .left:
                proposedContentOffset = .init(x: collectionView.contentOffset.x + collectionView.frame.size.width/2, y: .zero)
            default:
                return false
            }
            let targetContentOffset = (collectionView.collectionViewLayout as? ZoomAndSnapFlowLayout)?.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                                                                                                           withScrollingVelocity: .zero) ?? .zero
            collectionView.setContentOffset(targetContentOffset, animated: true)
            
            onMainQueueAfter(time: Constants.animationDuration) { [weak self] in
                self?.setVisibleItem(indexPath: self?.lastIndexPath)
            }
            
            return true
        }
        
        // Returning false to use the built-in VoiceOver scrolling
        return false
    }
    
    private func setupAccessibility() {
        statusTextView.isAccessibilityElement = true
        statusTextView.accessibilityLabel = R.Strings.documents_collection_accessibility_reachability_error.localized()
        scrollingPageControl.isAccessibilityElement = false
    }
}

// MARK: - View logic
extension DocumentsCollectionViewController: DocumentsCollectionView {
    func updateDocuments() {
        collectionView?.reloadData()
        if view.window == nil {
            needUpdatesUI = true
            return
        }
        updateUI(animated: true)
    }
    
    private func updateUI(animated: Bool) {
        needUpdatesUI = false
        (collectionView.collectionViewLayout as? ZoomAndSnapFlowLayout)?.cachedAttributes = []
        collectionView.layoutIfNeeded()
        var indexPath: IndexPath = visibleIndexPath ?? IndexPath(item: 0, section: 0)
        let count = presenter.numberOfItems()
        if indexPath.item >= count {
            indexPath.item = count - 1
        }
        forceUpdateIndexPath(index: indexPath, animated: animated)
        setVisibleItem(indexPath: indexPath, animated: animated)
            
        pagingData.total = presenter.numberOfItems()
    }
    
    func setStatusText(statusText: String?) {
        statusTextView?.labelText = statusText
        if statusText != nil {
            statusTextView?.isHidden = false
            statusTextView?.animate()
        } else {
            statusTextView?.isHidden = true
            statusTextView?.stopAnimation()
        }
    }
    
    func scroll(to indexPath: IndexPath, animated: Bool) {
        guard
            let flowLayout = collectionView.collectionViewLayout as? ZoomAndSnapFlowLayout,
            let cellFrame = flowLayout.layoutAttributesForItem(at: indexPath)?.frame
        else {
            return
        }
        
        let additionalOffset = (collectionView.bounds.width - cellFrame.width) / 2
        let offsetX = cellFrame.minX - additionalOffset
        
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
        forceUpdateIndexPath(index: indexPath)
        setVisibleItem(indexPath: indexPath, animated: false)
    }
    
    func onSharingRequestReceived() {
        guard
            let visibleIndexPath = visibleIndexPath,
            let cell = collectionView.cellForItem(at: visibleIndexPath) as? DocumentCollectionCell
        else {
            return
        }
        
        if cell.isFlipped { cell.flip() }
    }
    
    func flipCurrentItem() {
        if let indexPath = lastIndexPath, let cell = collectionView.cellForItem(at: indexPath) as? DocumentCollectionCell {
            cell.flip()
        }
    }
    
    func isVisible() -> Bool {
        return view.window != nil && !view.needsUpdateConstraints()
    }
}

// MARK: - UICollectionViewDataSource
extension DocumentsCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionCell.reuseID, for: indexPath) as? DocumentCollectionCell
            ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard
            let cell = cell as? DocumentCollectionCell,
            let dataType = presenter.itemAtIndex(index: indexPath.item)
        else {
            return
        }
        
        let moreAction = actionFabric?.getAction(for: dataType, view: self, flipper: cell)
        
        let viewModel = DocumentCollectionCellViewModel(
            documentData: dataType,
            contextMenuCallback: moreAction,
            cardStackCallback: { [weak self] in
                self?.presenter.stackClicked(at: indexPath.item)
            },
            accessibilityActionsMenuCallBack: makeAccessibilityMenuCallBack(for: indexPath, cell: cell)
        )
        
        cell.configure(with: viewModel)
        
        if let color = cardColorHex {
            cell.setBackgroundColor(color: UIColor(color))
        }
        
        let cellIsHidden = !(indexPath == visibleIndexPath || visibleIndexPath == nil)
        cell.setContentHidden(isHidden: cellIsHidden, animated: false)
    }
    
    private func makeAccessibilityMenuCallBack(for indexPath: IndexPath, cell: DocumentCollectionCell) -> Callback? {
        let callback: Callback?
        
        guard let dataType = presenter.itemAtIndex(index: indexPath.item) else { return nil }
        
        if dataType.count > 1 {
            callback = { [weak self] in
                guard let self else { return }

                if let indexPath = self.collectionView.indexPath(for: cell) {
                    presenter.stackClicked(at: indexPath.item)
                }
            }
        } else {
            callback = nil
        }
        
        return self.actionFabric?.getAccessibilityMenuActions(
            for: dataType,
            view: self,
            flipper: cell,
            openStackDocument: callback
        )
    }
}

// MARK: - UICollectionViewDelegate
extension DocumentsCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if indexPath == lastIndexPath {
            presenter.selectItem(index: indexPath.item)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        (collectionView.collectionViewLayout as? ZoomAndSnapFlowLayout)?.startCenterX = collectionView.contentOffset.x + collectionView.frame.size.width/2
        setVisibleItem(indexPath: nil)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setVisibleItem(indexPath: lastIndexPath)
    }
}

// MARK: - ZoomAndSnapFlowLayoutDelegate
extension DocumentsCollectionViewController: ZoomAndSnapFlowLayoutDelegate {
    func didChangeIndexPathInTheMiddle(_ indexPath: IndexPath?) {
        if let newIndex = indexPath, (lastIndexPath != newIndex) {
            forceUpdateIndexPath(index: newIndex)
        }
    }
    
    private func forceUpdateIndexPath(index: IndexPath, animated: Bool = true) {
        if let last = lastIndexPath, let cell = collectionView.cellForItem(at: last) as? DocumentCollectionCell {
            cell.shouldHide()
            cell.changeFocusing(isFocused: false)
        }
        if let cell = collectionView.cellForItem(at: index) as? DocumentCollectionCell {
            cell.changeFocusing(isFocused: true)
        }
        lastIndexPath = index
        pagingData.current = index.item
    }
}

// MARK: - MainEmbeddable
extension DocumentsCollectionViewController: MainEmbeddable {
    func onSameSelected() {
        let initialIndexPath = IndexPath(item: .zero, section: .zero)
        collectionView.scrollToItem(at: initialIndexPath, at: .centeredHorizontally, animated: true)
        
        forceUpdateIndexPath(index: initialIndexPath)
        setVisibleItem(indexPath: initialIndexPath, animated: false)
    }
    
    func processAction(action: String) {
        presenter.processAction(action: action)
    }
}

// MARK: - ScrollingPageControlAccessibilityActionsDelegate
extension DocumentsCollectionViewController: ScrollingPageControlAccessibilityActionsDelegate {
    func onScroll(direction: UIAccessibilityScrollDirection) {
        _ = accessibilityScroll(direction)
    }
}

// MARK: - Constants
extension DocumentsCollectionViewController {
    private enum Constants {
        static let scrollingDotColor = UIColor.init(white: 1, alpha: 0.4)
        static let animationDuration: TimeInterval = 0.25
        static let minAmountToShowPages = 2
        static let pagesAlpha: CGFloat = 0.3
        static let longPressDuration: TimeInterval = 0.3
        
        static var pageInset: CGFloat = 16
        
        static func maxDots(for totalPages: Int) -> Int {
            if totalPages < 6 {
                return totalPages
            } else {
                return 6
            }
        }
        
        static func centerDots(for totalPages: Int) -> Int {
            if totalPages < 4 {
                return totalPages
            } else {
                return 3
            }
        }
        static let dotSize: CGFloat = 8
    }
}
