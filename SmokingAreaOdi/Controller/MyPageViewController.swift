//
//  MyPageViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 9/17/25.
//

import FirebaseAuth

import UIKit

final class MyPageViewController : UIViewController {
  
  private let rootContainer = UIView()
  
  var userEmail: String = ""
  
  private let emailLabel = UILabel().then {
    $0.textColor = .black
    $0.font = $0.font.withSize(30)
    $0.textAlignment = .center
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    self.userEmail = Auth.auth().currentUser?.email ?? "사용자"
    
    self.addSubviews()
    self.setupLayout()
  }
  
  override func viewDidLayoutSubviews() {
    self.rootContainer.pin.all(self.view.pin.safeArea)
    self.rootContainer.flex.layout()
  }
  
  private func addSubviews() {
    self.view.addSubview(self.rootContainer)
  }
  
  private func setupLayout() {
    self.rootContainer.flex.direction(.column).define {
      $0.addItem(self.emailLabel)
        .grow(1)
        .marginTop(100)
        .alignSelf(.center)
    }
    self.emailLabel.text = "\(self.userEmail)님"
  }
}
