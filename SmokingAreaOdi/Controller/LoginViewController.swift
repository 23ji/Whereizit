//
//  LoginViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 9/16/25.
//

import FlexLayout
import KakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKAuth
import RxKakaoSDKCommon
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
    self.bindKakaoLogin()
    self.bindAction()
  }
  
  
  private func addSubviews() {
    self.view.addSubview(self.kakaoLoginButton)
    self.view.addSubview(self.skipButton)
  }
  
  private func setupLayout() {
    self.view.flex.direction(.column).define {
      $0.addItem(kakaoLoginButton)
                      .width(200)
                      .height(50)
                      .alignSelf(.center)
                      .marginTop(200)
                  $0.addItem(skipButton)
                      .width(200)
                      .height(50)
                      .alignSelf(.center)
                      .marginTop(20)
    }
    self.view.flex.layout(mode: .fitContainer)
  }
  
  
  private func bindKakaoLogin() {
   
  }
  
  
  private func bindAction() {
    
    self.kakaoLoginButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.loginKakao()
      })
      .disposed(by: disposeBag)
    
    self.skipButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.goHome()
      })
      .disposed(by: disposeBag)
  }
  
  
  private func loginKakao() {
    
  }
  
  private func goHome() {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }
            let tabBar = MainTabBarController()
            window.rootViewController = tabBar
            window.makeKeyAndVisible()
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
