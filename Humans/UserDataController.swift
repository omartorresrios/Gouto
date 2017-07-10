//
//  UserDataController.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class UserDataController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let backView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "back_button")!.withRenderingMode(.alwaysTemplate))
        image.tintColor = UIColor.mainBlue()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Regístrate"
        label.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        return label
    }()
    
    let fullnameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nombre y apellido"
        tf.autocapitalizationType = UITextAutocapitalizationType.words
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Correo"
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Contraseña (8 caracteres mín.)"
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.addTarget(self, action: #selector(handlePasswordCount), for: .editingChanged)
        return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continúa", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont(name: "SFUIDisplay-Semibold", size: 15)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.alpha = 1.0
        return indicator
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Regular", size: 12)
        label.textColor = UIColor.rgb(red: 234, green: 51, blue: 94)
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // General properties of the view
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // Others configurations
        fullnameTextField.becomeFirstResponder()
        
        // Initialize functions
        setupInputFields()
        
        // Reachability for checking internet connection
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    func handlePasswordCount() {
        let password = passwordTextField.text?.characters.count ?? 0
        
        if password == 0 {
            messageLabel.text = ""
        } else if password < 5 {
            messageLabel.text = "Débil 😕"
            messageLabel.textColor = UIColor.rgb(red: 234, green: 51, blue: 94)
        } else if password < 8 {
            messageLabel.text = "Bien 👍"
            messageLabel.textColor = UIColor.rgb(red: 255, green: 128, blue: 0)
        } else {
            messageLabel.text = "Fuerte! 😎"
            messageLabel.textColor = UIColor.rgb(red: 3, green: 165, blue: 136)
        }
    }
    
    func handleTextInputChange() {
        messageLabel.text = ""
        loader.stopAnimating()
        
        let isFormValid = emailTextField.text?.characters.count ?? 0 > 0 && fullnameTextField.text?.characters.count ?? 0 > 0 && passwordTextField.text?.characters.count ?? 0 >= 8
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .mainBlue()
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    func handleSignUp() {
        messageLabel.textColor = UIColor.rgb(red: 234, green: 51, blue: 94)
        messageLabel.text = ""
        loader.startAnimating()
        view.endEditing(true)
        
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            guard let email = emailTextField.text else { return }
            
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            
            if emailTest.evaluate(with: email) == true { // Valid email
                
                Database.database().reference().child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.value, with: { snapshot in
                    
                    if snapshot.exists() {
                        self.loader.stopAnimating()
                        self.messageLabel.text = "Ese correo ya está asociado a un nombre de usuario."
                        
                    } else {
                        
                        let signUpController = SignUpController()
                        signUpController.fullname = self.fullnameTextField
                        signUpController.email = self.emailTextField
                        signUpController.password = self.passwordTextField
                        
                        self.navigationController?.pushViewController(signUpController, animated: true)
                        self.loader.stopAnimating()
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                
            } else { // Invalid email
                self.loader.stopAnimating()
                self.messageLabel.text = "Introduce un correo válido por favor."
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Tu conexión a internet está fallando. 🤔 Intenta de nuevo.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.loader.stopAnimating()
        }
    }
    
    func goBackView() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupInputFields() {
        
        view.addSubview(backView)
        
        backView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 18, height: 18)
        
        let backViewTap = UITapGestureRecognizer(target: self, action: #selector(goBackView))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(backViewTap)
        
        view.addSubview(titleLabel)
        
        titleLabel.anchor(top: backView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 35, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [fullnameTextField, emailTextField, passwordTextField, signUpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 190)
        
        view.addSubview(loader)
        
        loader.anchor(top: stackView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
        loader.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor).isActive = true
        
        view.addSubview(messageLabel)
        
        messageLabel.anchor(top: stackView.bottomAnchor, left: stackView.leftAnchor, bottom: nil, right: stackView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}
