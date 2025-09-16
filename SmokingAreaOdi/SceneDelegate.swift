//
//  SceneDelegate.swift
//  SmokeAreaOdi
//
//  Created by 이상지 on 12/23/24.
//

import KakaoSDKAuth
import RxKakaoSDKAuth

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    
    let window = UIWindow(windowScene: windowScene)
    
    let homeVC = HomeViewController()
    homeVC.title = "Home"
    let mapImage = UIImage(systemName: "map")?
        .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15))
    homeVC.tabBarItem = UITabBarItem(title: "흡연구역", image: mapImage, tag: 0)
    let homeNav = UINavigationController(rootViewController: homeVC)
    
    let markerPositionSelectorVC = MarkerPositionSelectorViewController()
    markerPositionSelectorVC.title = "추가"
    let plusImage = UIImage(systemName: "plus")?
        .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15))
    markerPositionSelectorVC.tabBarItem = UITabBarItem(title: "추가", image: plusImage, tag: 1)
    let markerPositionSelectorNav = UINavigationController(rootViewController: markerPositionSelectorVC)
    
    let tabBarController = UITabBarController()
    tabBarController.viewControllers = [homeNav, markerPositionSelectorNav]
    
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithOpaqueBackground()
    tabBarAppearance.backgroundColor = .white
    tabBarController.tabBar.standardAppearance = tabBarAppearance
    tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
    
    window.rootViewController = LoginViewController()
    self.window = window
    window.makeKeyAndVisible()
  }
  
  
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
          if let url = URLContexts.first?.url {
              if (AuthApi.isKakaoTalkLoginUrl(url)) {
                  _ = AuthController.handleOpenUrl(url: url)
              }
          }
      }
  
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
  
  
}

