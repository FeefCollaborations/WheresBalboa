import UIKit

class TextFieldPromptViewController: UIViewController, UITextFieldDelegate {
    enum State {
        case prompting, loading, complete
    }
    
    typealias OperationCreationBlock = (String, @escaping ((String) -> ())) -> Void
    
    @IBOutlet private var promptContainerView: UIView!
    @IBOutlet private var promptLabel: UILabel!
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var submitButton: UIButton!
    
    @IBOutlet private var loadingView: LoadingView!
    
    @IBOutlet private var completionContainerView: UIView!
    @IBOutlet private var completionLabel: UILabel!
    
    private var state: State = .prompting
    
    private let promptText: String
    private let placeholderText: String
    private let operationCreationBlock: OperationCreationBlock
    
    // MARK: - Init
    
    init(promptText: String, placeholderText: String, operationCreationBlock: @escaping OperationCreationBlock) {
        self.promptText = promptText
        self.placeholderText = placeholderText
        self.operationCreationBlock = operationCreationBlock
        super.init(nibName: nil, bundle: nil)
        guard #available(iOS 11.0, *) else {
            edgesForExtendedLayout = []
            return
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promptLabel.text = promptText
        textField.placeholder = placeholderText
        updateState(to: .prompting)
        updateSubmitButtonInteractiveState()
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSubmitButtonInteractiveState()
        return true
    }
    
    // MARK: - Button response
    
    @IBAction private func tappedSubmitButton() {
        guard
            let inputString = textField.text,
            !inputString.isEmpty
        else {
            // TODO: Log error, shouldn't hit this
            return
        }
        
        updateState(to: .loading)
        operationCreationBlock(inputString) { [weak self] completionText in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.completionLabel.text = completionText
                strongSelf.updateState(to: .complete)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func updateSubmitButtonInteractiveState() {
        submitButton.isEnabled = textField.text?.isEmpty == false
    }
    
    private func updateState(to state: State) {
        let visibleView: UIView
        let hiddenViews: [UIView]
        switch state {
            case .prompting:
                visibleView = promptContainerView
                hiddenViews = [loadingView, completionContainerView]
            case .loading:
                visibleView = loadingView
                hiddenViews = [promptContainerView, completionContainerView]
            case .complete:
                visibleView = completionContainerView
                hiddenViews = [loadingView, promptContainerView]
        }
        visibleView.isHidden = false
        hiddenViews.forEach { $0.isHidden = true }
    }
}
