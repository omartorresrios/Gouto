//
//  Review.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import Foundation

struct Review {
    
    var id: String?
    
    let user: UserViewModel
    let fromFullname: String
    let content: String
    let fromId: String
    let fromProfileImageUrl: String
    let creationDate: Date
    let isPositive: Bool
    
    var hasLiked = false
    
    init(user: UserViewModel, dictionary: [String: Any]) {
        self.user = user
        self.fromFullname = dictionary["fromFullname"] as? String ?? ""
        self.content = dictionary["content"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.fromProfileImageUrl = dictionary["fromProfileImageUrl"] as? String ?? ""
        self.isPositive = dictionary["isPositive"] as? Bool ?? false
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}

