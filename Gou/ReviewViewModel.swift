//
//  ReviewViewModel.swift
//  Gou
//
//  Created by Omar Torres on 12/21/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import Foundation

struct ReviewViewModel {
    
    var id: String?
    
    let user: UserViewModel
    let fromFullname: String
    let content: String
    let fromId: String
    let fromProfileImageUrl: String
    let creationDate: Date
    let isPositive: Bool
    var hasLiked = false
    
    let captionLabel: NSAttributedString
    
    init(user: UserViewModel, review: Review) {
        self.user = user
        self.fromFullname = review.fromFullname
        self.content = review.content
        self.fromId = review.fromId
        self.fromProfileImageUrl = review.fromProfileImageUrl
        self.isPositive = review.isPositive
        self.creationDate = review.creationDate
        
        
        let attributedText = NSMutableAttributedString(string: review.fromFullname, attributes: [NSAttributedString.Key.font: nameFont])
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: spaceFont]))
        attributedText.append(NSAttributedString(string: "\(review.content)", attributes: [NSAttributedString.Key.font: contentFont]))
        captionLabel = attributedText
    }
}
