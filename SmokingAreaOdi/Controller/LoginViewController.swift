//
//  LoginViewController.swift
//  SmokingAreaOdi
//

import FlexLayout
import KakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKAuth
import RxKakaoSDKCommon
import RxKakaoSDKUser
import RxSwift
import Then
import UIKit
import FirebaseAuth
import FirebaseFunctions

final class LoginViewController: UIViewController {
  
  private enum Metric {
    static let imageButtonWidth: CGFloat = 200
    static let buttonWidth: CGFloat = 180
    static let buttonHeight: CGFloat = 50
  }
  
  private let disposeBag = DisposeBag()
  
  private let kakaoLoginButton = UIButton().then {
    $0.setImage(UIImage(named: "kakao_login_medium_narrow"), for: .normal)
  }
  
  private let signInButton = UIButton().then {
    $0.setTitle("회원가입", for: .normal)
    $0.backgroundColor = .systemGray4
    $0.layer.cornerRadius = 5
    $0.layer.masksToBounds = true
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
    self.bindAction()
  }
  
  private func addSubviews() {
    self.view.addSubview(self.kakaoLoginButton)
    self.view.addSubview(self.signInButton)
    self.view.addSubview(self.skipButton)
  }
  
  private func setupLayout() {
    self.view.flex.direction(.column).define {
      $0.addItem(self.kakaoLoginButton)
        .width(Metric.imageButtonWidth)
        .height(Metric.buttonHeight)
        .alignSelf(.center)
        .marginTop(200)
      $0.addItem(self.signInButton)
        .width(Metric.buttonWidth)
        .height(Metric.buttonHeight)
        .alignSelf(.center)
        .padding(10)
        .marginTop(20)
      $0.addItem(self.skipButton)
        .width(Metric.buttonWidth)
        .height(Metric.buttonHeight)
        .alignSelf(.center)
        .marginTop(20)
    }
    self.view.flex.layout(mode: .fitContainer)
  }
  
  private func bindAction() {
    self.kakaoLoginButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.loginKakao()
      })
      .disposed(by: disposeBag)
    
    self.signInButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.signIn()
      })
      .disposed(by: disposeBag)
    
    self.skipButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.goHome()
      })
      .disposed(by: disposeBag)
  }
  
  private func loginKakao() {
    let functions = Functions.functions(region: "us-central1")
    
    if UserApi.isKakaoTalkLoginAvailable() {
      UserApi.shared.rx.loginWithKakaoTalk()
        .subscribe(onNext: { oauthToken in
          let kakaoToken = oauthToken.accessToken
          print("카카오 토큰 (from KakaoTalk):", kakaoToken)
          
          // Firebase Function 호출
          let callable = functions.httpsCallable("kakaoLogin")
          callable.call(["accessToken": kakaoToken]) { result, error in
            if let error = error as NSError? {
              print("Firebase Function 호출 에러:", error.localizedDescription)
              print("에러 코드:", error.code)
              print("에러 도메인:", error.domain)
              return
            }
            if let token = (result?.data as? [String: Any])?["token"] as? String {
              Auth.auth().signIn(withCustomToken: token) { authResult, error in
                if let user = authResult?.user {
                  print("Firebase 로그인 성공: \(user.uid)")
                  self.goHome()
                } else if let error = error {
                  print("Firebase 커스텀 토큰 로그인 에러:", error.localizedDescription)
                }
              }
            }
          }
        }, onError: { error in
          print("카카오톡 로그인 에러:", error.localizedDescription)
        })
        .disposed(by: disposeBag)
    } else {
      UserApi.shared.rx.loginWithKakaoAccount()
        .subscribe(onNext: { oauthToken in
          let kakaoToken = oauthToken.accessToken
          print("카카오 토큰 (from KakaoAccount):", kakaoToken)
          
          let callable = functions.httpsCallable("kakaoLogin")
          callable.call(["accessToken": kakaoToken]) { result, error in
            if let error = error as NSError? {
              print("Firebase Function 호출 에러:", error.localizedDescription)
              print("에러 코드:", error.code)
              print("에러 도메인:", error.domain)
              return
            }
            if let token = (result?.data as? [String: Any])?["token"] as? String {
              Auth.auth().signIn(withCustomToken: token) { authResult, error in
                if let user = authResult?.user {
                  print("Firebase 로그인 성공: \(user.uid)")
                  self.goHome()
                } else if let error = error {
                  print("Firebase 커스텀 토큰 로그인 에러:", error.localizedDescription)
                }
              }
            }
          }
        }, onError: { error in
          print("카카오 계정 로그인 에러:", error.localizedDescription)
        })
        .disposed(by: disposeBag)
    }
  }
  
  
  private func signIn() {
    let signInVC = SignInViewController()
    self.present(signInVC, animated: true)
  }
  
  func goHome() {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = scene.windows.first else { return }
    let tabBar = MainTabBarController()
    window.rootViewController = tabBar
    window.makeKeyAndVisible()
  }
}
