//
//  UserRankingCell.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

class UserRankingCell: UICollectionViewCell {
    
    var userViewModel: UserViewModel! {
        didSet {
            fullnameLabel.text = userViewModel.fullname
            
            let profileImageUrl = userViewModel.profileImageUrl
            profileImageView.loadImage(urlString: profileImageUrl)
            
            pointsLabel.text = "\(userViewModel.points)"
            
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let fullnameLabel: UILabel = {
        let fl = UILabel()
        fl.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        return fl
    }()
    
    let pointsLabel: UILabel = {
        let pl = UILabel()
        pl.font = UIFont(name: "SFUIDisplay-Bold", size: 14)
        return pl
    }()
    
    let numberLabel: UILabel = {
        let nl = UILabel()
        nl.font = UIFont(name: "SFUIDisplay-Semibold", size: 23)
        return nl
    }()
    
    let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(numberLabel)
        numberLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(mainView)
        mainView.addSubview(profileImageView)
        mainView.addSubview(fullnameLabel)
        mainView.addSubview(pointsLabel)
        
        // Shadow effect
        mainView.layer.cornerRadius = 3.0
        mainView.layer.masksToBounds = false
        mainView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        mainView.layer.shadowOffset = CGSize(width: 0, height: 2)
        mainView.layer.shadowOpacity = 0.8
        
        mainView.anchor(top: topAnchor, left: numberLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 30, width: 0, height: 0)
        
        profileImageView.anchor(top: nil, left: mainView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        
        setupNameAndPoints()
        
    }
    
    fileprivate func setupNameAndPoints() {
        let stackView = UIStackView(arrangedSubviews: [fullnameLabel, pointsLabel])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        
        addSubview(stackView)
        stackView.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        stackView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
