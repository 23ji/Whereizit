//
//  SignInViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 9/18/25.
//

import FlexLayout
import Then

import UIKit

class SignInViewController: UIViewController {
  
  
  private let emailLabel = UILabel().then{
    $0.text = "Email"
  }
  
  private let emailTextFeild = UITextField().then{
    $0.borderStyle = .roundedRect
  }
  
  private let passwordLabel = UILabel().then{
    $0.text = "Password"
  }
  
  private let passwordTextFeild = UITextField().then{
    $0.borderStyle = .roundedRect
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addSubviews()
    self.setupLayout()
  }
  
  private func addSubviews() {
    self.view.addSubview(self.emailLabel)
    self.view.addSubview(self.emailTextFeild)
    self.view.addSubview(self.passwordLabel)
    self.view.addSubview(self.passwordTextFeild)
  }
  
  private func setupLayout() {
    self.view.backgroundColor = .white
    self.view.flex.direction(.column).define {
      $0.addItem(self.emailLabel).width(200).height(50).alignSelf(.center).marginTop(200)
      $0.addItem(self.emailTextFeild).width(200).height(50).alignSelf(.center)
      $0.addItem(self.passwordLabel).width(200).height(50).alignSelf(.center)
      $0.addItem(self.passwordTextFeild).width(200).height(50).alignSelf(.center)
    }
    self.view.flex.layout(mode: .fitContainer)
  }
}
