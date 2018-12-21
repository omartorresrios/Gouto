//
//  LoginController.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let backView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "back_button")!.withRenderingMode(.alwaysTemplate))
        image.tintColor = UIColor.mainBlue()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Inicia sesión"
        label.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        return label
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
        tf.placeholder = "Contraseña"
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Inicia sesión", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont(name: "SFUIDisplay-Semibold", size: 15)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.gray)
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
        setupView()
        setupInputFields()
    }
    
    func setupView() {
        view.backgroundColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isHidden = true
        
        emailTextField.becomeFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func handleTextInputChange() {
        messageLabel.text = ""
        loader.stopAnimating()
        
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    @objc func handleLogin() {
        view.endEditing(true)
        loader.startAnimating()
        
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            guard let email = emailTextField.text else { return }
            let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
            
            guard let password = passwordTextField.text else { return }
            
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            
            if emailTest.evaluate(with: email) == true { // Valid email
                
                Database.database().reference().child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.value, with: { snapshot in
                    
                    if snapshot.exists() {
                        
                        // Login user
                        Auth.auth().signIn(withEmail: finalEmail, password: password, completion: { (user, err) in
                            
                            if let err = err {
                                print("Failed to sign in with email:", err)
                                self.loader.stopAnimating()
                                self.messageLabel.text = "La contraseña no es válida."
                                return
                            }
                            
                            print("Successfully logged back in with user:", user?.uid ?? "")
                            
                            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                            
                            mainTabBarController.setupViewControllers(completion: { (success) in
                                if success {
                                    self.loader.stopAnimating()
                                }
                            })
                            
                            self.dismiss(animated: true, completion: nil)
                            
                        })
                        
                    } else {
                        self.loader.stopAnimating()
                        self.messageLabel.text = "No podemos encontrar una cuenta con ese correo."
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
                
            } else { // Invalid email
                self.loader.stopAnimating()
                self.messageLabel.text = "Introduce un correo válido por favor."
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Tu conexión a internet está fallando. 🤔 Intenta de nuevo.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.loader.stopAnimating()
        }
        
    }
    
    @objc func goBackView() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupInputFields() {
        
        view.addSubview(backView)
        
        backView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 18, height: 18)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(goBackView))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tap)
        
        view.addSubview(titleLabel)
        
        titleLabel.anchor(top: backView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 35, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
        
        view.addSubview(loader)
        
        loader.anchor(top: stackView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 10, height: 10)
        loader.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        
        view.addSubview(messageLabel)
        
        messageLabel.anchor(top: stackView.bottomAnchor, left: stackView.leftAnchor, bottom: nil, right: stackView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}
