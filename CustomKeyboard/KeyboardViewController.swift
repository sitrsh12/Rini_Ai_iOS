import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {

    private var hostingController: UIHostingController<CustomKeyboardView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardView()
    }

    private func setupKeyboardView() {
        // Create and configure the SwiftUI view
        let customKeyboardView = CustomKeyboardView(viewController: self)
        hostingController = UIHostingController(rootView: customKeyboardView)
        
        // Add the SwiftUI view as a child view controller
        if let hostingController = hostingController {
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            hostingController.didMove(toParent: self)
        }
        
        let switchKeyboardButton = UIButton(type: .system)
        switchKeyboardButton.setTitle("Next Keyboard", for: .normal)
        switchKeyboardButton.addTarget(self, action: #selector(switchToNextKeyboard), for: .touchUpInside)
    
        

        let getTextButton = UIButton(type: .system)
        getTextButton.setTitle("Get Text", for: .normal)
        getTextButton.addTarget(self, action: #selector(getCurrentText), for: .touchUpInside)
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Dismiss Keyboard", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissKeyboardProgrammatically), for: .touchUpInside)
        
    }

    func updateText(_ text: String) {
        textDocumentProxy.setMarkedText(text, selectedRange: NSRange(location: text.count, length: 0))
    }

    // Handle button tap to send text
    @objc private func sendButtonTapped() {
        let text = textDocumentProxy.documentIdentifier
        updateText(text.uuidString)
    }
    
    @objc func switchToNextKeyboard() {
        advanceToNextInputMode()
    }
    
    @objc func getCurrentText() -> String {
        // Safely unwrap textDocumentProxy and fetch text before the cursor
        let beforeText: String = textDocumentProxy.documentContextBeforeInput ?? ""
        let afterText: String = textDocumentProxy.documentContextAfterInput ?? ""
        
        // Combine or return relevant text
        return beforeText + afterText
    }
    
    func replaceText(with newText: String) {
        while textDocumentProxy.hasText {
               textDocumentProxy.deleteBackward()
           }
        textDocumentProxy.insertText(newText)
    }
    
    @objc func dismissKeyboardProgrammatically() {
        // Dismiss the keyboard
        dismissKeyboard()
    }
}
