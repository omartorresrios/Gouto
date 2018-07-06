//
//  User.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let email: String
    let fullname: String
    let profileImageUrl: String
    let points: Int
    let reviewsCount: Int
    let isValidated: Bool
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.reviewsCount = dictionary["reviewsCount"] as? Int ?? 0
        self.points = dictionary["points"] as? Int ?? 0
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.isValidated = dictionary["isValidated"] as? Bool ?? false
    }
}
