//
//  LoginVC.swift
//  FirebaseApp
//
//  Created by Sofa on 12.11.23.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginVC: UIViewController {
    
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!
    
    @IBOutlet weak var warnLbl: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warnLbl.alpha = 0
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener({ [weak self] _, user in
            guard let _ = user else { return }
            self?.performSegue(withIdentifier: "GoToTasksTVC", sender: nil)
        })
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
        emailTF.delegate = self
        passwordTF.delegate = self
    }
    
    
    @IBAction func logInAction() {
        guard let email = emailTF.text, !email.isEmpty,
              let pass = passwordTF.text, !pass.isEmpty
        else {
            displayWarningLbl(withText: "Info is incorect")
            return
        }
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] user, error in
            if let error = error {
                self?.displayWarningLbl(withText: "Error: \(error)")
            } else if let _ = user {
                self?.performSegue(withIdentifier: "GoToTasksTVC", sender: nil)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        Auth.auth().removeStateDidChangeListener(authStateDidChangeListenerHandle)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTF.text = nil
        passwordTF.text = nil
    }
    

    @objc private func kbWillShow(notification: Notification){
        view.frame.origin.y = 0
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.origin.y -= keyboardSize.height / 2
        }
    }
    @objc private func kbWillHide(){
        view.frame.origin.y = 0
   }
    private func displayWarningLbl(withText text: String) {
        warnLbl.text = text
        UIView.animate(withDuration: 3,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
                           self?.warnLbl.alpha = 1
                       }
        ) { [weak self] _ in
            self?.warnLbl.alpha = 0
            self?.warnLbl.text = nil
        }
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
