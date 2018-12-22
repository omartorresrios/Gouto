//
//  HomeReviewCell.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

protocol HomeReviewCellDelegate {
    func didTapComment(review: ReviewViewModel)
    func didLike(for cell: HomeReviewCell)
}

class HomeReviewCell: UICollectionViewCell {
    
    var delegate: HomeReviewCellDelegate?
    
    var userProfileController = UserProfileController()
    
    var reviewViewModel: ReviewViewModel? {
        didSet {
            
            guard let profileImageUrl = reviewViewModel?.fromProfileImageUrl else { return }
            
            if profileImageUrl == "" {
                userProfileImageView.image = #imageLiteral(resourceName: "humans_icon")
            } else {
                userProfileImageView.loadImage(urlString: profileImageUrl)
            }
            
            captionLabel.attributedText = reviewViewModel?.captionLabel
            
            if reviewViewModel?.isPositive == true {
                captionLabel.addSubview(dotImage)
                dotImage.anchor(top: mainView.topAnchor, left: mainView.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 5, height: 5)
                dotImage.tintColor = UIColor.mainGreen()
            } else {
                captionLabel.addSubview(dotImage)
                dotImage.anchor(top: mainView.topAnchor, left: mainView.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 5, height: 5)
                dotImage.tintColor = UIColor.rgb(red: 246, green: 30, blue: 66)
            }
        }
    }
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    func handleLike() {
        delegate?.didLike(for: self)
    }
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    @objc func handleComment() {
        guard let review = reviewViewModel else { return }
        delegate?.didTapComment(review: review)
    }
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let dotImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = #imageLiteral(resourceName: "dot").withRenderingMode(.alwaysTemplate)
        return image
    }()
    
    let arrowImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = #imageLiteral(resourceName: "down_arrow").withRenderingMode(.alwaysTemplate)
        return image
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let arrowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mainView)
        
        mainView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        
        mainView.layer.cornerRadius = 3.0
        mainView.layer.masksToBounds = false
        mainView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        mainView.layer.shadowOffset = CGSize(width: 0, height: 2)
        mainView.layer.shadowOpacity = 0.8
        
        mainView.addSubview(userProfileImageView)
        
        userProfileImageView.anchor(top: mainView.topAnchor, left: mainView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        mainView.addSubview(arrowView)
        arrowView.anchor(top: mainView.topAnchor, left: nil, bottom: nil, right: mainView.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 20, height: 20)
        
        arrowView.addSubview(arrowImage)
        arrowImage.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 13, height: 13)
        arrowImage.centerXAnchor.constraint(equalTo: arrowView.centerXAnchor).isActive = true
        arrowImage.centerYAnchor.constraint(equalTo: arrowView.centerYAnchor).isActive = true
        arrowImage.tintColor = UIColor(white: 0.4, alpha: 1)
        
        mainView.addSubview(captionLabel)
        captionLabel.anchor(top: mainView.topAnchor, left: userProfileImageView.rightAnchor, bottom: mainView.bottomAnchor, right: arrowView.leftAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
