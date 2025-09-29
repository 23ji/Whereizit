//
//  LoginButton.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 9/26/25.
//

import UIKit

enum LoginType {
  case login
  case google
  case apple
  case kakao
  case signIn
}


final class LoginButton: UIButton {
  
  init(type: LoginType) {
    super.init(frame: .zero)
    self.setupButton(type: type)
  }
  
  required init?(coder: NSCoder) {
    fatalError("버튼 생성 오류")
  }
  
  private func setupButton(type: LoginType) {
    var configuration = UIButton.Configuration.plain()
    configuration.imagePadding = 12
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14)
    
    self.layer.cornerRadius = 5
    self.layer.masksToBounds = true
    
    switch type {
      
    case .login:
      configuration.title = "로그인"
      configuration.baseForegroundColor = .white
      self.backgroundColor = .darkGray

    case .google:
      configuration.image = UIImage(named: "googleLoginButton")
      configuration.title = "Google로 시작하기"
      configuration.baseForegroundColor = .black
      self.backgroundColor = .white
      self.layer.borderWidth = 0.5
      self.layer.borderColor = UIColor.gray.cgColor
      
    case .kakao:
      configuration.image = UIImage(named: "kakaoLoginButton")
      configuration.title = "카카오로 시작하기"
      configuration.baseForegroundColor = .black
      self.backgroundColor = UIColor(hexCode: "FEE500")
      
    case .apple:
      configuration.title = "apple로 시작하기"
      
    case .signIn:
      configuration.title = "이메일로 시작하기"
      configuration.baseForegroundColor = .white
      self.backgroundColor = .lightGray
    }
    self.configuration = configuration
  }
}


extension UIColor {
  
  convenience init(hexCode: String, alpha: CGFloat = 1.0) {
    var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
    if hexFormatted.hasPrefix("#") {
      hexFormatted = String(hexFormatted.dropFirst())
    }
    
    assert(hexFormatted.count == 6, "Invalid hex code used.")
    
    var rgbValue: UInt64 = 0
    Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
    
    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
              alpha: alpha)
  }
}
