//
//  UserSearchController.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Firebase
import JDStatusBarNotification
import PopupDialog

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let popUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Dejando reseñas ganarás puntos que te servirán para mejorar tu reputación. De pasada que haces del mundo un lugar más justo."
        label.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Busca a alguien..."
        sb.setValue("Cancelar", forKey:"_cancelButtonText")
        sb.delegate = self
        return sb
    }()
    
    let spaceItem: UIBarButtonItem = {
        let si = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        return si
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.gray)
        indicator.alpha = 1.0
        indicator.startAnimating()
        return indicator
    }()
    
    let messageLabel: UILabel = {
        let ml = UILabel()
        ml.font = UIFont.systemFont(ofSize: 12)
        ml.numberOfLines = 0
        ml.textAlignment = .center
        return ml
    }()
    
    var filteredUsers = [User]()
    var users = [User]()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearchBar()
        fetchUsers()
        showPopUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.tabBarController?.tabBar.isHidden = false
        searchBar.isHidden = false
        
        collectionView?.register(UserSearchHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "searchHeaderId")
        
        if Auth.auth().currentUser?.uid == "2X5pTpJJoPaGNQjoq2g09rXx71f2" {
            setupLogOutButton()
        }
    }
    
    func setupCollectionView() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        navigationController?.navigationBar.addSubview(searchBar)
        navigationController?.navigationBar.barTintColor = UIColor.mainBlue()
        
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.addSubview(loader)
        let indicatorYStartPosition = (navigationController?.navigationBar.frame.size.height)! + 10
        loader.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: indicatorYStartPosition)
        
        // Position the messageLabel
        view.addSubview(messageLabel)
        messageLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setupSearchBar() {
        for subView: UIView in searchBar.subviews {
            for field: Any in subView.subviews {
                if (field is UITextField) {
                    let textField: UITextField? = (field as? UITextField)
                    textField?.backgroundColor = UIColor.clear
                }
            }
        }
        
        let attributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.white, convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont(name: "SFUIDisplay-Regular", size: 17)]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary(attributes as [String : Any]), for: .normal)
        
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = .white
        textFieldInsideUISearchBar?.font = UIFont(name: "SFUIDisplay-Regular", size: 18)
        
        let placeholderLabel = textFieldInsideUISearchBar?.value(forKey: "placeholderLabel") as? UILabel
        placeholderLabel?.font = UIFont(name: "SFUIDisplay-Regular", size: 18)
        placeholderLabel?.textColor = .white
        
        let glassIconView = textFieldInsideUISearchBar?.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = .white
        glassIconView.frame.size.width = 15
        glassIconView.frame.size.height = 15
        
        // Position the searchbar
        let navBar = navigationController?.navigationBar
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.fullname.lowercased().contains(searchText.lowercased())
            }
        }
        
        if filteredUsers.isEmpty {
            messageLabel.isHidden = false
            messageLabel.text = "🙁 No encontramos a esa persona."
        } else {
            messageLabel.isHidden = true
        }
        
        self.collectionView?.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    fileprivate func fetchUsers() {
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
                    
                    return u1.fullname.compare(u2.fullname) == .orderedAscending
                    
                })
                
                self.filteredUsers = self.users
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
    
    func showPopUp() {
        if UserDefaults.standard.bool(forKey: "searchPopUp") == false {
            UserDefaults.standard.set(true, forKey: "searchPopUp")
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
            dialogAppearance.layer.cornerRadius         = 4
            
            let popup = PopupDialog(title: "¡Esto te intereserá! 😎", message: popUpLabel.text)
            
            let buttonOne = CancelButton(title: "¡Busquemos a alguien! 👉") {
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
    
    @objc func reachabilityStatusChanged() {
        print("Checking connectivity...")
    }
    
    @objc func goToAddPeopleController() {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let addPeopleController = AddPeopleController(collectionViewLayout: UICollectionViewFlowLayout())
        addPeopleController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(addPeopleController, animated: true)
    }
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Salir 😞", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                //what happens? we need to present some kind of login controller
                let loginController = StartViewController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let user = filteredUsers[indexPath.item]
        
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        userProfileController.userFullname = user.fullname
        userProfileController.userImageUrl = user.profileImageUrl
        
        userProfileController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 32) / 3
        return CGSize(width: width, height: width + 20)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "searchHeaderId", for: indexPath) as! UserSearchHeader
        header.backgroundColor = UIColor.mainBlue()
        header.addPeopleButton.addTarget(self, action: #selector(goToAddPeopleController), for: .touchUpInside)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 31)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
