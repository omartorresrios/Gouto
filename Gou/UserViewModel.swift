//
//  UserViewModel.swift
//  Gou
//
//  Created by Omar Torres on 12/21/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import Foundation
import UIKit

struct UserViewModel {
    
    let uid: String
    let email: String
    let fullname: String
    let profileImageUrl: String
    let points: Int
    let reviewsCount: Int
    let isValidated: Bool
    
    let reviewsLabel: NSAttributedString
    let pointsLabel: NSAttributedString
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.fullname = user.fullname
        self.reviewsCount = user.reviewsCount
        self.points = user.points
        self.profileImageUrl = user.profileImageUrl
        self.isValidated = user.isValidated
        
        let attributedReview = NSMutableAttributedString(string: "\(user.reviewsCount)", attributes: [NSAttributedString.Key.font: numbersFont!])
        if user.reviewsCount == 1 {
            attributedReview.append(NSAttributedString(string: " reseña", attributes: [NSAttributedString.Key.font: normalFont!]))
        } else {
            attributedReview.append(NSAttributedString(string: " reseñas", attributes: [NSAttributedString.Key.font: normalFont!]))
        }
        reviewsLabel = attributedReview
        
        
        let attributedPoint = NSMutableAttributedString(string: "\(user.points)", attributes: [NSAttributedString.Key.font: numbersFont!])
        if user.points == 1 || user.points == -1 {
            attributedPoint.append(NSAttributedString(string: " punto", attributes: [NSAttributedString.Key.font: normalFont!]))
        } else {
            attributedPoint.append(NSAttributedString(string: " puntos", attributes: [NSAttributedString.Key.font: normalFont!]))
        }
        pointsLabel = attributedPoint
    }
}
