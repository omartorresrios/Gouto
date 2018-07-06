//
//  WriteReviewController.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Firebase
import M13Checkbox
import JDStatusBarNotification

class WriteReviewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    var anonymous: String = "Anónimo"
    var values: [String : Any] = [:]
    var user: User?
    var userReceiverId: String?
    
    var userReceiverFullname: String? {
        didSet {
            fullnameLabel.text = userReceiverFullname
        }
    }
    
    var userReceiverImageUrl: String? {
        didSet {
            guard let profileImageUrl = userReceiverImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    let topView: UIView = {
        let uv = UIView()
        uv.backgroundColor = .white
        return uv
    }()
    
    let pointsAnimateView: UIView = {
        let uv = UIView()
        uv.backgroundColor = UIColor.mainGreen()
        uv.isHidden = true
        return uv
    }()
    
    let poinsAnimateLabel: UILabel = {
        let ul = UILabel()
        ul.text = "+1"
        ul.textColor = .white
        ul.font = UIFont(name: "SFUIDisplay-Medium", size: 30)
        return ul
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let fullnameLabel: UILabel = {
        let ul = UILabel()
        ul.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        return ul
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_button"), for: .normal)
        button.isUserInteractionEnabled = true
        button.tintColor = UIColor.mainBlue()
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    let writeReviewTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        tv.autocorrectionType = .no
        tv.textContainerInset = UIEdgeInsetsMake(10, 7, 5, 0)
        return tv
    }()
    
    let placeholderLabel: UILabel = {
        let pl = UILabel()
        pl.text = "Comienza a escribir tu reseña aquí..."
        pl.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        pl.sizeToFit()
        pl.frame.origin = CGPoint(x: 10, y: 10)
        pl.textColor = UIColor.lightGray
        return pl
    }()
    
    let bottomSeparatorView: UIView = {
        let sv = UIView()
        sv.backgroundColor = UIColor.lightGray
        return sv
    }()
    
    let limitLabel: UILabel = {
        let ll = UILabel()
        ll.text = "500"
        ll.font = UIFont(name: "SFUIDisplay-Regular", size: 12)
        return ll
    }()
    
    let positiveReview: UIImageView = {
        var pr = UIImageView()
        pr.image = #imageLiteral(resourceName: "happy_face_unselected")
        return pr
    }()
    
    let negativeReview: UIImageView = {
        var nr = UIImageView()
        nr.image = #imageLiteral(resourceName: "sad_face_unselected")
        return nr
    }()
    
    let keyboardToolbar: UIToolbar = {
        let kt = UIToolbar()
        kt.sizeToFit()
        kt.isTranslucent = false
        kt.barStyle = .blackTranslucent
        kt.barTintColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        return kt
    }()
    
    let spaceItem: UIBarButtonItem = {
        let si = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        return si
    }()
    
    let sendReviewButton: UIBarButtonItem = {
        let sb = UIBarButtonItem(title: "ENVIAR", style: .plain, target: self, action: #selector(handleSendReview))
        if let font = UIFont(name: "SFUIDisplay-Semibold", size: 15) {
            sb.setTitleTextAttributes([NSFontAttributeName: font,NSForegroundColorAttributeName: UIColor.white], for: .normal)
        }
        sb.isEnabled = false
        return sb
    }()
    
    let checkbox: M13Checkbox = {
        let cb = M13Checkbox()
        cb.tintColor = UIColor.mainGreen()
        cb.secondaryTintColor = UIColor.rgb(red: 85, green: 85, blue: 85)
        cb.addTarget(self, action: #selector(checkboxReview), for: UIControlEvents.valueChanged)
        return cb
    }()
    
    let anonymousLabel: UILabel = {
        let ll = UILabel()
        ll.text = "En anónimo"
        ll.font = UIFont(name: "SFUIDisplay-Regular", size: 12)
        return ll
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.alpha = 1.0
        indicator.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // General properties of the view
        collectionView?.backgroundColor = UIColor.rgb(red: 247, green: 247, blue: 247)
        navigationController?.navigationBar.barTintColor = .white
        
        // Others configurations
        writeReviewTextView.becomeFirstResponder()
        self.writeReviewTextView.delegate = self
        
        // Initialize functions
        subviewsAnchors()
        
        // Reachability for checking internet connection
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func reachabilityStatusChanged() {
        print("Checking connectivity...")
    }
    
    func handleTextInputChange() {
        let isFormValid = writeReviewTextView.text?.characters.count ?? 0 > 0
        
        if isFormValid {
            sendReviewButton.isEnabled = true
            keyboardToolbar.barTintColor = .mainBlue()
        } else {
            sendReviewButton.isEnabled = false
            keyboardToolbar.barTintColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    func handleSendReview() {
        view.endEditing(true)
        loader.startAnimating()
        
        guard let review = writeReviewTextView.text else { return }
        
        guard let senderId = Auth.auth().currentUser?.uid else { return } // sender user
        
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            Database.database().reference().child("users").child(senderId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    guard let fullname = dictionary["fullname"] as? String else { return }
                    guard let profileImageUrl = dictionary["profileImageUrl"] as? String else { return }
                    
                    if self.checkbox.checkState == .unchecked { // not anonymous review
                        if self.positiveReview.image == #imageLiteral(resourceName: "happy_face_selected") {
                            self.values = ["fromId": senderId, "fromFullname": fullname, "fromProfileImageUrl": profileImageUrl, "isPositive": true, "content": review, "creationDate": Date().timeIntervalSince1970]
                        } else if self.negativeReview.image == #imageLiteral(resourceName: "sad_face_selected") {
                            self.values = ["fromId": senderId, "fromFullname": fullname, "fromProfileImageUrl": profileImageUrl, "isPositive": false, "content": review, "creationDate": Date().timeIntervalSince1970]
                        }
                        
                    } else if self.checkbox.checkState == .checked { // anonymous review
                        if self.positiveReview.image == #imageLiteral(resourceName: "happy_face_selected") {
                            self.values = ["fromId": senderId, "fromFullname": self.anonymous, "fromProfileImageUrl": "", "isPositive": true, "content": review, "creationDate": Date().timeIntervalSince1970]
                        } else if self.negativeReview.image == #imageLiteral(resourceName: "sad_face_selected") {
                            self.values = ["fromId": senderId, "fromFullname": self.anonymous, "fromProfileImageUrl": "", "isPositive": false, "content": review, "creationDate": Date().timeIntervalSince1970]
                        }
                    }
                    
                    self.updateChild(values: self.values)
                    self.loader.stopAnimating()
                    self.givePointsAnimation()
                    
                }
            }, withCancel: nil)
            
        } else {
            JDStatusBarNotification.show(withStatus: "Revisa tu conexión e intenta de nuevo", dismissAfter: 5.0, styleName: JDStatusBarStyleDark)
        }
    }
    
    func givePointsAnimation() {
        pointsAnimateView.isHidden = false
        pointsAnimateView.alpha = 1.0
        pointsAnimateView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 4.0, options: .allowUserInteraction, animations: {
            self.pointsAnimateView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (success) in
            self.pointsAnimateView.isHidden = true
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateChild(values: [String : Any]) {
        guard let receiverId = userReceiverId else { return } // receiver user
        guard let senderId = Auth.auth().currentUser?.uid else { return } // sender user
        
        let userReviewRef = Database.database().reference().child("reviews").child(receiverId)
        let ref = userReviewRef.childByAutoId()
        
        if positiveReview.image == #imageLiteral(resourceName: "happy_face_selected") || negativeReview.image == #imageLiteral(resourceName: "sad_face_selected") {
            
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    self.sendReviewButton.isEnabled = true
                    print("Failed to save review to DB", err)
                    return
                }
                
                print("Successfully saved review to DB")
                
                Database.database().reference().child("users").child(receiverId).child("reviewsCount").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                    var value = currentData.value as? Int
                    if value == nil  {
                        value = 1
                    }
                    currentData.value = value! + 1
                    
                    return TransactionResult.success(withValue: currentData)
                })
                
                // Give +1 point if the review its positive and rest -1 if its negative
                Database.database().reference().child("users").child(receiverId).child("points").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                    
                    var value = currentData.value as? Int
                    
                    if self.positiveReview.image == #imageLiteral(resourceName: "happy_face_selected") {
                        if value == nil  {
                            value = 1
                        }
                        currentData.value = value! + 1
                        
                    } else if self.negativeReview.image == #imageLiteral(resourceName: "sad_face_selected") {
                        if value == nil  {
                            value = -1
                        }
                        currentData.value = value! - 1
                        
                    }
                    
                    return TransactionResult.success(withValue: currentData)
                    
                })
                
                // Give +1 point to the user who wrote the review
                Database.database().reference().child("users").child(senderId).child("points").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                    
                    var value = currentData.value as? Int
                    if value == nil  {
                        value = 1
                    }
                    
                    currentData.value = value! + 1
                    
                    return TransactionResult.success(withValue: currentData)
                    
                })
                
            }
        } else {
            JDStatusBarNotification.show(withStatus: "Elige si es una reseña positiva o negativa", dismissAfter: 2.0, styleName: JDStatusBarStyleDark)
        }
        
    }
    
    func checkboxReview() {
        if checkbox.checkState == .checked {
            JDStatusBarNotification.show(withStatus: "Reseña anónima", dismissAfter: 2.0, styleName: JDStatusBarStyleDark)
        } else if checkbox.checkState == .unchecked {
            JDStatusBarNotification.show(withStatus: "Reseña pública", dismissAfter: 2.0, styleName: JDStatusBarStyleDark)
        }
    }
    
    func positiveReview(tapGestureRecognizer: UITapGestureRecognizer) {
        positiveReview.image = #imageLiteral(resourceName: "happy_face_selected")
        negativeReview.image = #imageLiteral(resourceName: "sad_face_unselected")
        
        JDStatusBarNotification.show(withStatus: "Reseña positiva", dismissAfter: 2.0, styleName: JDStatusBarStyleDark)
    }
    
    func negativeReview(tapGestureRecognizer: UITapGestureRecognizer) {
        negativeReview.image = #imageLiteral(resourceName: "sad_face_selected")
        positiveReview.image = #imageLiteral(resourceName: "happy_face_unselected")
        
        JDStatusBarNotification.show(withStatus: "Reseña negativa", dismissAfter: 2.0, styleName: JDStatusBarStyleDark)
    }
    
    func subviewsAnchors() {
        
        keyboardToolbar.items = [spaceItem, sendReviewButton, spaceItem]
        writeReviewTextView.inputAccessoryView = keyboardToolbar
        
        navigationController?.navigationBar.addSubview(topView)
        
        let heightTopView = self.navigationController!.navigationBar.frame.height
        
        view.addSubview(writeReviewTextView)
        view.addSubview(limitLabel)
        view.addSubview(bottomSeparatorView)
        view.addSubview(positiveReview)
        view.addSubview(negativeReview)
        view.addSubview(checkbox)
        view.addSubview(anonymousLabel)
        view.addSubview(loader)
        
        // Anchors for all elements
        
        let navBar = navigationController?.navigationBar
        
        topView.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: heightTopView)
        
        topView.addSubview(closeButton)
        topView.addSubview(profileImageView)
        topView.addSubview(fullnameLabel)
        
        profileImageView.anchor(top: topView.topAnchor, left: topView.leftAnchor, bottom: topView.bottomAnchor, right: fullnameLabel.leftAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 4, width: 36, height: 36)
        profileImageView.layer.cornerRadius = 36 / 2
        profileImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        
        fullnameLabel.anchor(top: topView.topAnchor, left: nil, bottom: nil, right: closeButton.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 0, height: 0)
        fullnameLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        
        closeButton.anchor(top: nil, left: nil, bottom: nil, right: topView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 15, height: 15)
        closeButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        closeButton.addTarget(self, action: #selector(exitWriteReviewController), for: .touchUpInside)
        
        writeReviewTextView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: heightTopView + 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        writeReviewTextView.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !writeReviewTextView.text.isEmpty
        
        bottomSeparatorView.anchor(top: writeReviewTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        
        limitLabel.anchor(top: writeReviewTextView.bottomAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        positiveReview.anchor(top: writeReviewTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: negativeReview.leftAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 25, height: 25)
        let tapGesForPositive = UITapGestureRecognizer(target: self, action: #selector(positiveReview(tapGestureRecognizer:)))
        positiveReview.isUserInteractionEnabled = true
        positiveReview.addGestureRecognizer(tapGesForPositive)
        
        negativeReview.anchor(top: writeReviewTextView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        let tapGesForNegative = UITapGestureRecognizer(target: self, action: #selector(negativeReview(tapGestureRecognizer:)))
        negativeReview.isUserInteractionEnabled = true
        negativeReview.addGestureRecognizer(tapGesForNegative)
        
        checkbox.anchor(top: writeReviewTextView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        checkbox.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        anonymousLabel.anchor(top: checkbox.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        anonymousLabel.centerXAnchor.constraint(equalTo: checkbox.centerXAnchor).isActive = true
        
        view.addSubview(pointsAnimateView)
        pointsAnimateView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        pointsAnimateView.layer.cornerRadius = 100 / 2
        pointsAnimateView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pointsAnimateView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        pointsAnimateView.addSubview(poinsAnimateLabel)
        poinsAnimateLabel.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        poinsAnimateLabel.centerXAnchor.constraint(equalTo: pointsAnimateView.centerXAnchor).isActive = true
        poinsAnimateLabel.centerYAnchor.constraint(equalTo: pointsAnimateView.centerYAnchor).isActive = true
        
        
    }
    
    func exitWriteReviewController() {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        let isFormValid = writeReviewTextView.text?.characters.count ?? 0 > 10
        
        if isFormValid {
            sendReviewButton.isEnabled = true
            keyboardToolbar.barTintColor = .mainBlue()
        } else {
            sendReviewButton.isEnabled = false
            keyboardToolbar.barTintColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        
        // Movements to limit characters
        let remainChar:Int = 500 - newLength
        
        limitLabel.text = "\(remainChar)"
        
        if remainChar == -1 {
            limitLabel.text = "0"
            limitLabel.textColor = UIColor.red
        } else {
            if remainChar <= 20 {
                limitLabel.textColor = UIColor.orange
            } else {
                limitLabel.textColor = UIColor.black
                limitLabel.text = "\(remainChar)"
            }
        }
        return (newLength > 500) ? false : true
    }
}
