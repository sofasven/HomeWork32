//
//  Task.swift
//  FirebaseApp
//
//  Created by Sofa on 13.11.23.
//

import Foundation
import Firebase

struct Task {
    let title: String
    let userId: String
    var isCompleted: Bool = false
    let ref: DatabaseReference!
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    
    init?(snapshot: DataSnapshot) {
        guard let snapshotValue = snapshot.value as? [String: Any],
              let title = snapshotValue[Constants.titleKey] as? String,
              let userId = snapshotValue[Constants.userIdKey] as? String,
              let isCompleted = snapshotValue[Constants.isCompletedKey] as? Bool else { return nil }
        self.title = title
        self.userId = userId
        self.isCompleted = isCompleted
        self.ref = snapshot.ref
    }
    
    func convertToDictionary() -> [String: Any] {
        [Constants.titleKey: title,
         Constants.userIdKey: userId,
         Constants.isCompletedKey: isCompleted]
    }
    
    private enum Constants {
        static let titleKey = "title"
        static let userIdKey = "userId"
        static let isCompletedKey = "isCompleted"
        
    }
}
