
import UIKit
import Lottie
import DiiaMVPModule
import DiiaUIComponents

protocol DocumentsStackView: BaseView {
    func setupChild(module: BaseModule)
    func setupTitle(title: String)
    func setBackgroundImage(image: UIImage?)
}

final class DocumentsStackViewController: UIViewController, Storyboarded {

    // MARK: - Outlets
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var childContainerView: UIView!
    @IBOutlet private weak var backgroundColorView: UIView!
    @IBOutlet private weak var backgroundAnimationView: LottieAnimationView!

    @IBOutlet weak private var topConstraint: NSLayoutConstraint!
    
	// MARK: - Properties
	var presenter: DocumentsStackAction!
    private var child: UIViewController?
    private var colorObservation: NSKeyValueObservation?
    
	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupAnimation()
        setupAccessibility()
        presenter.configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundAnimationView.stop()
    }
    
    // MARK: - Configuration
    func setupViews() {
        titleLabel.font = FontBook.smallHeadingFont
        topConstraint.constant = Constants.topInset
    }
    
    // MARK: - Private Methods
    @IBAction private func backButtonTapped() {
        closeModule(animated: true)
    }
    
    private func setupAnimation() {
        backgroundAnimationView.animation = .named("background_gradient", bundle: Bundle.module)
        backgroundAnimationView.loopMode = .loop
        backgroundAnimationView.backgroundBehavior = .pauseAndRestore
        backgroundAnimationView.contentMode = .scaleAspectFill
        backgroundAnimationView.play()
    }
    
    // MARK: - Accessibility
    private func setupAccessibility() {
        backButton.isAccessibilityElement = true
        backButton.accessibilityTraits = .button
        backButton.accessibilityLabel = R.Strings.general_accessibility_back.localized()
    }
}

// MARK: - View logic
extension DocumentsStackViewController: DocumentsStackView {
    func setupChild(module: BaseModule) {
        if let child = self.child {
            VCChildComposer.removeChild(child, from: self, animationType: .none)
        }
        self.child = module.viewController()
        VCChildComposer.addChild(module.viewController(), to: self, in: childContainerView, animationType: .none)
        colorObservation = module.viewController().view.observe(\.backgroundColor, onChange: { [weak self] (color) in
            self?.backgroundColorView.backgroundColor = color
        })
    }
    
    func setupTitle(title: String) {
        titleLabel.text = title
    }
    
    func setBackgroundImage(image: UIImage?) {}
}

// MARK: - Constants
extension DocumentsStackViewController {
    private enum Constants {
        static var topInset: CGFloat {
            switch UIDevice.size() {
            case .screen4Inch:
                return 16
            case .screen5_5Inch, .screen6_1Inch, .screen6_5Inch:
                return 39
            default:
                return 30
            }
        }
    }
}
