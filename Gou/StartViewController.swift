//
//  StartViewController.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    let logo: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "humans_icon")
        return image
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("INICIA SESIÓN", for: .normal)
        button.layer.borderWidth = 3.0
        button.layer.borderColor = UIColor.mainBlue().cgColor
        button.layer.cornerRadius = 30//40 / 2//5.0
        button.titleLabel?.font = UIFont(name: "SFUIDisplay-Semibold", size: 17)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("REGÍSTRATE", for: .normal)
        button.layer.borderWidth = 3.0
        button.layer.borderColor = UIColor.mainGreen().cgColor
        button.layer.cornerRadius = 30//5.0
        button.titleLabel?.font = UIFont(name: "SFUIDisplay-Semibold", size: 17)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(goToSignUp), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupView() {
        view.backgroundColor = .white
        let backgroundImage = UIImageView(image: UIImage(named: "friends.jpg")!)
        backgroundImage.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        backgroundImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    @objc func goToLogin() {
        let loginController = LoginController()
        navigationController?.pushViewController(loginController, animated: true)
    }
    
    @objc func goToSignUp() {
        let userDataController = UserDataController()
        navigationController?.pushViewController(userDataController, animated: true)
    }
    
    fileprivate func setupButtons() {
        
        view.addSubview(logo)
        logo.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [loginButton, signUpButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 40, paddingBottom: 40, paddingRight: 40, width: 0, height: 130)
    }
    
}
