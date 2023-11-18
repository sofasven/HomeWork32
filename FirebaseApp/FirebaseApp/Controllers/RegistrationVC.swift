//
//  RegistrationVC.swift
//  FirebaseApp
//
//  Created by Sofa on 12.11.23.
//

import UIKit
import Firebase
import FirebaseAuth

class RegistrationVC: UIViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLbl.alpha = 0
        ref = Database.database().reference(withPath: "users")
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
        emailTF.delegate = self
        passTF.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func addUser() {
        guard let email = emailTF.text, !email.isEmpty,
              let pass = passTF.text, !pass.isEmpty
        else {
            displayWarningLbl(withText: "Info is incorect")
            return
        }
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] user, error in
            if let error = error {
                self?.displayWarningLbl(withText: "Error: \(error)")
            } else if let user = user {
                let userRef = self?.ref.child(user.user.uid)
                userRef?.setValue(["email": user.user.email])
                Auth.auth().signIn(withEmail: email, password: pass) { [weak self] user, error in
                    if let error = error {
                        self?.displayWarningLbl(withText: "Error: \(error)")
                    } else if let _ = user {
                        self?.performSegue(withIdentifier: "FromRegToTasks", sender: nil)
                    }
                }
            }
        }
    }

    private func displayWarningLbl(withText text: String) {
        errorLbl.text = text
        UIView.animate(withDuration: 3,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
                           self?.errorLbl.alpha = 1
                       }
        ) { [weak self] _ in
            self?.errorLbl.alpha = 0
            self?.errorLbl.text = nil
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc private func kbWillShow(notification: Notification){
        view.frame.origin.y = 0
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.origin.y -= keyboardSize.height / 2
        }
    }
    @objc private func kbWillHide(){
        view.frame.origin.y = 0
   }
}

extension RegistrationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
