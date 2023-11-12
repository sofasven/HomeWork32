//
//  RegistrationVC.swift
//  FirebaseApp
//
//  Created by Sofa on 12.11.23.
//

import UIKit
import Firebase

class RegistrationVC: UIViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLbl.alpha = 0
        ref = Database.database().reference(withPath: "users")
    }
    @IBAction func addUser() {
        guard let email = emailTF.text, !email.isEmpty,
              let pass = passTF.text, !pass.isEmpty
        else {
            // info is incorrect
            return
        }
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] user, error in
            if let error = error {
                print(error)
                // info is incorrect
            } else if let user = user {
                let userRef = self?.ref.child(user.user.uid)
                userRef?.setValue(["email": user.user.email])
            }
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

}
