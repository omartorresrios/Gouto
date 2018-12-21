//
//  MainTabBarController.swift
//  Humans
//
//  Created by Omar Torres on 9/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        checkLoggedIn()
        setupViewControllers { (success) in
            print("setup success")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        tabBar.isHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func setupView() {
        tabBar.isHidden = true
        
        let backgroundImage = UIImageView(image: UIImage(named: "friends.jpg")!)
        backgroundImage.contentMode = .scaleAspectFill
        
        view.insertSubview(backgroundImage, at: 0)
        backgroundImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        self.delegate = self
    }
    
    func checkLoggedIn() {
        if Auth.auth().currentUser == nil {
            //show if not logged in
            DispatchQueue.main.async {
                let startViewController = StartViewController()
                let navController = UINavigationController(rootViewController: startViewController)
                self.present(navController, animated: false, completion: nil)
            }
            return
        }
    }
    
    func setupViewControllers(completion: @escaping Callback) {
        
        // Search
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // Ranking
        let layout = UICollectionViewFlowLayout()
        let userRankingController = UserRankingController(collectionViewLayout: layout)
        
        let userRankingNavController = UINavigationController(rootViewController: userRankingController)
        
        userRankingNavController.tabBarItem.image = #imageLiteral(resourceName: "ranking_unselected")
        userRankingNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "ranking_selected")
        
        tabBar.tintColor = UIColor.mainBlue()
        
        viewControllers = [searchNavController, userRankingNavController]
        
        completion(true)
        
        //modify tab bar item insets
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}
