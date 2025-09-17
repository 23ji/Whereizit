//
//  LoginViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 9/16/25.
//

import FlexLayout
import RxSwift
import Then

import UIKit

final class LoginViewController: UIViewController {

  private let disposeBag = DisposeBag()

  private let kakaoLoginButton = UIButton().then {
    $0.setImage(UIImage(named: "kakao_login_medium_narrow"), for: .normal)
  }
  
  private let skipButton = UIButton().then {
    let title = "로그인 건너뛰기"
        let attributedString = NSAttributedString(
            string: title,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.gray
            ]
        )
        $0.setAttributedTitle(attributedString, for: .normal)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.addSubviews()
    self.setupLayout()
  }
  
  
  private func addSubviews() {
    self.view.addSubview(self.kakaoLoginButton)
  }
  
  private func setupLayout() {
    self.view.flex.direction(.column).define {
      $0.addItem(self.kakaoLoginButton).margin(10).grow(1)
      $0.addItem(self.skipButton).margin(10).grow(1)
    }
    self.view.flex.layout(mode: .fitContainer)
  }
  
  /*
   // 카카오톡 실행 가능 여부 확인
   if (UserApi.isKakaoTalkLoginAvailable()) {
       UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
           if let error = error {
               print(error)
           }
           else {
               print("loginWithKakaoTalk() success.")

               // 성공 시 동작 구현
               _ = oauthToken
           }
       }
   }
   */
}
