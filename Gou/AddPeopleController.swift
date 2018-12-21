//
//  AddPeopleController.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import PopupDialog

class AddPeopleController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let backView: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "back_button")
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 18)
        label.text = "Agrega a alguien"
        label.textColor = UIColor.mainGreen()
        return label
    }()
    
    let addSomeoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        
        let attributedText = NSMutableAttributedString(string: "Envía los siguientes datos a este correo ", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "SFUIDisplay-Regular", size: 14)!]))
        
        attributedText.append(NSAttributedString(string: "addhumans1@gmail.com :", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "SFUIDisplay-Semibold", size: 14)!])))
        
        attributedText.append(NSAttributedString(string: "\n\n\n\n", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "SFUIDisplay-Regular", size: 4)!])))
        
        attributedText.append(NSAttributedString(string: "1) Nombre y apellido: ", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "SFUIDisplay-Medium", size: 14)!])))
        
        attributedText.append(NSAttributedString(string: "Puede ser solo nombre.", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "SFUIDisplay-Regular", size: 14)!])))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "SFUIDisplay-Regular", size: 4)!])))
        
        attributedText.append(NSAttributedString(string: "2) Foto: ", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "SFUIDisplay-Medium", size: 14)!])))
        
        attributedText.append(NSAttributedString(string: "Preferible que se note bien su rostro.", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "SFUIDisplay-Regular", size: 14)!])))
        
        attributedText.append(NSAttributedString(string: "\n\n\n\n\n\n", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "SFUIDisplay-Regular", size: 4)!])))
        
        attributedText.append(NSAttributedString(string: "¡Ah! y no olvides poner tu nombre en el asunto. ¡Así podremos darte los puntos! 🙂", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(name: "SFUIDisplay-Medium", size: 15)!])))
        
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "add_photo.png").withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage =
            info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
    let fullnameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nombre y apellido"
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("¡Agrégalo(a)!", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "SFUIDisplay-Semibold", size: 15)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc func handleTextInputChange() {
        let isFormValid = fullnameTextField.text?.characters.count ?? 0 > 0
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .mainBlue()
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(backToSearchCV), name: NSNotification.Name(rawValue: "GoToSearchFromAddPeople"), object: nil)
        
        navigationController?.isNavigationBarHidden = true
        navigationController?.tabBarController?.tabBar.isHidden = true
        
        collectionView?.backgroundColor = .white
        
        setupInputFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    @objc func backToSearchCV() {
        _ = navigationController?.popViewController(animated: true)
        navigationController?.isNavigationBarHidden = false
    }
    
    fileprivate func setupInputFields() {
        
        view.addSubview(backView)
        
        backView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 18, height: 18)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backToSearchCV))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tap)
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: backView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 35, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if Auth.auth().currentUser?.uid == "2X5pTpJJoPaGNQjoq2g09rXx71f2" {
            
            view.addSubview(plusPhotoButton)
            
            plusPhotoButton.anchor(top: titleLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
            
            plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            let stackView = UIStackView(arrangedSubviews: [fullnameTextField, signUpButton])
            stackView.distribution = .fillEqually
            stackView.axis = .vertical
            stackView.spacing = 10
            
            view.addSubview(stackView)
            
            stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 90)
            
        } else {
            view.addSubview(addSomeoneLabel)
            addSomeoneLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
            addSomeoneLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            addSomeoneLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
        
    }
    
    func random(_ n: Int) -> String {
        let a = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        
        var s = ""
        
        for _ in 0..<n {
            let r = Int(arc4random_uniform(UInt32(a.characters.count)))
            
            s += String(a[a.index(a.startIndex, offsetBy: r)])
        }
        
        return s
    }
    
    @objc func handleSignUp() {
        guard let fullname = fullnameTextField.text, fullname.characters.count > 0 else { return }
        
        let email = random(15) + "@example.com"
        let password = arc4random_uniform(1000000) // or another random number
        
        Auth.auth().createUser(withEmail: email, password: String(password), completion: { (user, error) in
            if let err = error {
                print("Failed to create user:", err)
                return
            }
            
            print("Successfully created user:", user?.uid ?? "")
            
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
            
            let filename = NSUUID().uuidString
            
            Storage.storage().reference().child("fake_users").child("profile_images").child(filename).putData(uploadData, metadata: nil, completion: { (metadata, err) in
                
                if let err = err {
                    print("Failed to upload profile image:", err)
                    return
                }
                
                guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
                
                print("Successfully uploaded profile image:", profileImageUrl)
                
                guard let uid = user?.uid else { return }
                
                let dictionaryValues = ["fullname": fullname, "reviewsCount": 0, "points": 0, "email": email, "profileImageUrl": profileImageUrl, "isValidated": false] as [String : Any]
                let values = [uid: dictionaryValues]
                
                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    if let err = err {
                        print("Failed to save user info into db:", err)
                        return
                    }
                    
                    print("Successfully saved user info to db")
                    
                    // Give a point to current use for create another user
                    let currentUserId = Auth.auth().currentUser?.uid
                    
                    Database.database().reference().child("users").child(currentUserId!).child("points").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                        var value = currentData.value as? Int
                        if value == nil  {
                            value = 1
                        }
                        currentData.value = value! + 1
                        
                        return TransactionResult.success(withValue: currentData)
                    })
                    
                    // LOG OUT…
                    try! Auth.auth().signOut()
                    
                    // …and log back into Admin (with whatever login info they have)
                    Auth.auth().signIn(withEmail: "omar@example.com", password: "12345678") { (user, error) in
                        // Check for any errors
                        if let error = error {
                            print(error)
                        } else {
                            // All done, new account created!
                            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                            
                            mainTabBarController.setupViewControllers(completion: { (success) in
                                if success {
                                    // Here present a pop or something for communicate the user is created succesfully
                                    UIApplication.shared.isStatusBarHidden = false
                                }
                            })
                        }
                    }
                    
                })
                
            })
            
        })
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
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
