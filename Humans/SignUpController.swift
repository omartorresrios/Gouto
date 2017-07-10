//
//  SignUpController.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let userImgDefault = UIImage(named: "add_photo.png")
    
    let backView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "back_button")!.withRenderingMode(.alwaysTemplate))
        image.tintColor = UIColor.mainBlue()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    var fullname: UITextField = {
        let tf = UITextField()
        return tf
    }()
    var email: UITextField = {
        let tf = UITextField()
        return tf
    }()
    var password: UITextField = {
        let tf = UITextField()
        return tf
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Intenta subir una foto que resalte tu rostro para que puedan reconocerte."
        label.font = UIFont(name: "SFUIDisplay-Regular", size: 12)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    let plusPhotoButton: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "add_photo.png")
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("¡Vamos!", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont(name: "SFUIDisplay-Semibold", size: 15)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.alpha = 1.0
        return indicator
    }()
    
    let termsServiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 0
        
        let attributedTitle = NSMutableAttributedString(string: "Continuando, aceptas nuestros Términos de Servicio.", attributes: [NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 12)!, NSForegroundColorAttributeName:UIColor(white: 0.5, alpha: 1)])
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowTermsOfService), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // General properties of the view
        view.backgroundColor = .white
        
        // Initialize functions
        setupViews()
        
        // Reachability for checking internet connection
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        
        if plusPhotoButton.image!.isEqual(userImgDefault) {
            print("es igual")
            signUpButton.isUserInteractionEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        } else {
            print("no es igual")
            signUpButton.isUserInteractionEnabled = true
            signUpButton.backgroundColor = .mainBlue()
        }
    }
    
    func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoButton.image = editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage =
            info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.image = originalImage.withRenderingMode(.alwaysOriginal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func handleShowTermsOfService() {
        let termsOfServiceController = TermsOfServiceController()
        navigationController?.pushViewController(termsOfServiceController, animated: true)
    }
    
    func goBackView() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func handleSignUp() {
        view.endEditing(true)
        loader.startAnimating()
        
        if (reachability?.isReachable)! {
            guard let userFullname = fullname.text, userFullname.characters.count > 0 else { return }
            guard let userEmail = email.text, userEmail.characters.count > 0 else { return }
            guard let userPassword = password.text, userPassword.characters.count > 0 else { return }
            
            Auth.auth().createUser(withEmail: userEmail, password: userPassword, completion: { (user, error) in
                if let err = error {
                    print("Failed to create user:", err)
                    return
                }
                
                print("Successfully created user:", user?.uid ?? "")
                
                guard let image = self.plusPhotoButton.image else { return }
                
                guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
                
                let filename = NSUUID().uuidString
                Storage.storage().reference().child("profile_images").child(filename).putData(uploadData, metadata: nil, completion: { (metadata, err) in
                    
                    if let err = err {
                        print("Failed to upload profile image:", err)
                        return
                    }
                    
                    guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
                    
                    print("Successfully uploaded profile image:", profileImageUrl)
                    
                    guard let uid = user?.uid else { return }
                    
                    let dictionaryValues = ["fullname": userFullname, "reviewsCount": 0, "points": 0, "email": userEmail, "profileImageUrl": profileImageUrl, "isValidated": true] as [String : Any]
                    let values = [uid: dictionaryValues]
                    
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                        
                        if let err = err {
                            print("Failed to save user info into db:", err)
                            return
                        }
                        
                        print("Successfully saved user info to db")
                        
                        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                        
                        mainTabBarController.setupViewControllers(completion: { (success) in
                            if success {
                                self.loader.stopAnimating()
                            }
                        })
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    })
                    
                })
            })
            
        } else {
            let alert = UIAlertController(title: "Error", message: "Tu conexión a internet está fallando. 🤔 Intenta de nuevo.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.loader.stopAnimating()
        }
    }
    
    func setupViews() {
        view.addSubview(backView)
        
        backView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 18, height: 18)
        
        let backViewTap = UITapGestureRecognizer(target: self, action: #selector(goBackView))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(backViewTap)
        
        view.addSubview(messageLabel)
        
        messageLabel.anchor(top: backView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 35, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 0)
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePlusPhoto))
        plusPhotoButton.addGestureRecognizer(tap)
        
        plusPhotoButton.anchor(top: messageLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(signUpButton)
        
        signUpButton.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 40)
        
        view.addSubview(termsServiceButton)
        termsServiceButton.anchor(top: signUpButton.bottomAnchor, left: signUpButton.leftAnchor, bottom: nil, right: signUpButton.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(loader)
        
        loader.anchor(top: termsServiceButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
        loader.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor).isActive = true
    }
    
}
