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

  private func setupButton(type: LoginType) {

    var configuration = UIButton.Configuration.plain()
    configuration.imagePadding = 12
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14)

    let title: String = switch type {
    case .login: "로그인"
    case .google: "Google로 시작하기"
    case .kakao: "카카오로 시작하기"
    case .apple: "Apple로 시작하기"
    case .signIn: "이메일로 시작하기"
    }

    let imageName: String? = switch type {
    case .google: "googleLoginButton"
    case .kakao: "kakaoLoginButton"
    default: nil
    }

    let bgColor: UIColor = switch type {
    case .login: .darkGray
    case .google: .white
    case .kakao: UIColor(hexCode: "FEE500")
    case .apple: .black
    case .signIn: .lightGray
    }

    let titleColor: UIColor = if type == .login || type == .signIn {
      .white
    } else {
      .black
    }

    configuration.title = title
    configuration.baseForegroundColor = titleColor

    if let imageName {
      configuration.image = UIImage(named: imageName)
    }

    self.backgroundColor = bgColor

    if type == .google {
      self.layer.borderWidth = 0.5
      self.layer.borderColor = UIColor.gray.cgColor
    }

    self.layer.cornerRadius = 5
    self.layer.masksToBounds = true

    self.configuration = configuration
  }
}
