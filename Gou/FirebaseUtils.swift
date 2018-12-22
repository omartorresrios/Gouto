//
//  FirebaseUtils.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (UserViewModel) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            let finalUser = UserViewModel(user: user)
            completion(finalUser)
            
        }) { (err) in
            print("Failed to fetch user for posts:", err)
        }
    }
}
