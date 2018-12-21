//
//  UserRankingController.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Firebase
import PopupDialog

class UserRankingController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let popUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Ellos son los que mejor reputación tienen hasta ahora. ¿Te imaginas todas las oportunidades que podrías tener gracias a Humans?"
        label.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.gray)
        indicator.alpha = 1.0
        indicator.startAnimating()
        return indicator
    }()
    
    var users = [User]()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        showPopUp()
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let font = UIFont(name: "SFUIDisplay-Medium", size: 18) else { return }
        navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: font, NSAttributedString.Key.foregroundColor.rawValue: UIColor.white])
        self.navigationItem.title = "Ranking de reputación"
    }
    
    func setupCollectionView() {
        collectionView?.backgroundColor = .white
        
        collectionView?.addSubview(loader)
        let indicatorYStartPosition = (navigationController?.navigationBar.frame.size.height)! + 10
        loader.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: indicatorYStartPosition)
        
        navigationController?.navigationBar.barTintColor = UIColor.mainGreen()
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        collectionView?.register(UserRankingCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.alwaysBounceVertical = false
        collectionView?.keyboardDismissMode = .onDrag
        
        // Reachability for checking internet connection
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func reachabilityStatusChanged() {
        print("Checking connectivity...")
    }
    
    func showPopUp() {
        if UserDefaults.standard.bool(forKey: "rankingPopUp") == false {
            UserDefaults.standard.set(true, forKey: "rankingPopUp")
            UserDefaults.standard.synchronize()
            
            let overlayAppearance = PopupDialogOverlayView.appearance()
            overlayAppearance.color       = UIColor.black
            overlayAppearance.blurRadius  = 20
            overlayAppearance.blurEnabled = false
            overlayAppearance.liveBlur    = false
            overlayAppearance.opacity     = 0.4
            
            let dialogAppearance = PopupDialogDefaultView.appearance()
            
            dialogAppearance.backgroundColor      = UIColor.white
            dialogAppearance.titleFont            = UIFont(name: "SFUIDisplay-Medium", size: 15)!
            dialogAppearance.titleColor           = UIColor(white: 0.4, alpha: 1)
            dialogAppearance.titleTextAlignment   = .center
            dialogAppearance.messageFont          = UIFont(name: "SFUIDisplay-Regular", size: 14)!
            dialogAppearance.messageColor         = UIColor(white: 0.5, alpha: 1)
            dialogAppearance.messageTextAlignment = .center
            dialogAppearance.layer.cornerRadius   = 4
            
            let popup = PopupDialog(title: "👏 🌍 🙌", message: popUpLabel.text, image: #imageLiteral(resourceName: "social_reputation.png"))
            
            let buttonOne = CancelButton(title: "¡Vamos!") {
                print("You canceled the car dialog.")
            }
            
            CancelButton.appearance().titleFont      = UIFont(name: "SFUIDisplay-Medium", size: 16)!
            CancelButton.appearance().titleColor     = UIColor.white
            CancelButton.appearance().buttonColor    = UIColor.mainGreen()
            CancelButton.appearance().separatorColor = UIColor.mainGreen()
            
            popup.addButtons([buttonOne])
            
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let user = users[indexPath.item]
        print("user selected: \(user.fullname)")
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileController.userId = user.uid
        userProfileController.userFullname = user.fullname
        userProfileController.userImageUrl = user.profileImageUrl
        
        userProfileController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(userProfileController, animated: true)
        
    }
    
    fileprivate func fetchUsers() {
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            let ref = Database.database().reference().child("users")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionaries = snapshot.value as? [String: Any] else { return }
                print("dictionaries: \(dictionaries)")
                dictionaries.forEach({ (key, value) in
                    
                    if key == Auth.auth().currentUser?.uid {
                        print("Found myself, omit from list")
                        return
                    }
                    
                    guard let userDictionary = value as? [String: Any] else { return }
                    
                    let user = User(uid: key, dictionary: userDictionary)
                    self.users.append(user)
                })
                
                self.users.sort(by: { (u1, u2) -> Bool in
                    
                    return u1.points > u2.points
                    
                })
                
                self.collectionView?.reloadData()
                
                self.loader.stopAnimating()
                
            }) { (err) in
                print("Failed to fetch users for search:", err)
            }
        } else {
            self.loader.stopAnimating()
            
            let alert = UIAlertController(title: "Error", message: "Tu conexión a internet está fallando. 🤔 Intenta de nuevo.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserRankingCell
        
        cell.numberLabel.text = "\((indexPath.row) + 1)"
        
        if indexPath.row == 0 {
            cell.numberLabel.textColor = UIColor.mainBlue()
        } else if indexPath.row > 0 && indexPath.row <= 9 {
            cell.numberLabel.textColor = UIColor.mainGreen()
        } else {
            cell.numberLabel.textColor = .black
        }
        cell.user = users[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
