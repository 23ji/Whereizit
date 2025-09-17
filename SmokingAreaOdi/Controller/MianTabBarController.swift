//
//  MianTabBarController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 9/17/25.
//

import UIKit

final class MainTabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let homeVC = UINavigationController(rootViewController: HomeViewController())
    homeVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
    
    let myPageVC = UINavigationController(rootViewController: MyPageViewContoller())
    myPageVC.tabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(systemName: "person"), tag: 1)
    
    viewControllers = [homeVC, myPageVC]
  }
}
