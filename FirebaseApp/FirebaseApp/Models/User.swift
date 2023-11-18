//
//  User.swift
//  FirebaseApp
//
//  Created by Sofa on 13.11.23.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email: String
    
    init(user: Firebase.User) {
        uid = user.uid
        email = user.email ?? ""
    }
}
