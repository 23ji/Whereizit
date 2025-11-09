//
//  AppStarter.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 11/9/25.
//

import Foundation
import UIKit

final class AppStarter {
  func start(in window: UIWindow){
    let loginViewController = LoginViewController()
    window.rootViewController = loginViewController
    window.makeKeyAndVisible()
  }
}
