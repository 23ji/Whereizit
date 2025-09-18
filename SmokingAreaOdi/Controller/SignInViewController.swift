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
  
  private enum Metric {
    static let labelWidth : CGFloat = 300
    static let labelHeight : CGFloat = 50
    static let textFieldWidth : CGFloat = 300
    static let textFieldHeight : CGFloat = 50
    static let buttonWidth : CGFloat = 300
    static let buttonHeight : CGFloat = 50
  }
  
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
  
  private let signinButtton = UIButton().then {
    $0.setTitle("회원가입", for: .normal)
    $0.backgroundColor = .systemGray
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
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
    self.view.addSubview(self.signinButtton)
  }
  
  private func setupLayout() {
    self.view.backgroundColor = .white
    self.view.flex.direction(.column).define {
      $0.addItem(self.emailLabel).width(Metric.labelWidth).height(Metric.labelHeight).alignSelf(.center).marginTop(200)
      $0.addItem(self.emailTextFeild).width(Metric.textFieldWidth).height(Metric.textFieldHeight).alignSelf(.center)
      $0.addItem(self.passwordLabel).width(Metric.labelWidth).height(Metric.labelHeight).alignSelf(.center)
      $0.addItem(self.passwordTextFeild).width(Metric.textFieldWidth).height(Metric.textFieldHeight).alignSelf(.center)
      $0.addItem(self.signinButtton).width(Metric.buttonWidth).height(Metric.buttonHeight).alignSelf(.center).marginTop(50)
    }
    self.view.flex.layout(mode: .fitContainer)
  }
}
