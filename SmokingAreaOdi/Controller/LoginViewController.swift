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
import FirebaseCore
import GoogleSignIn

final class LoginViewController: UIViewController {
  
  private enum Metric {
    static let imageButtonWidth: CGFloat = 200
    static let buttonWidth: CGFloat = 180
    static let buttonHeight: CGFloat = 50
    static let labelWidth : CGFloat = 300
    static let labelHeight : CGFloat = 50
    static let textFieldWidth : CGFloat = 300
    static let textFieldHeight : CGFloat = 50
  }
  
  private let disposeBag = DisposeBag()
  
  
  private let emailLabel = UILabel().then{
    $0.text = "Email"
  }
  
  private let emailTextFeild = UITextField().then{
    $0.borderStyle = .roundedRect
    $0.autocapitalizationType = .none
  }
  
  private let passwordLabel = UILabel().then{
    $0.text = "Password"
  }
  
  private let passwordTextFeild = UITextField().then{
    $0.borderStyle = .roundedRect
    $0.isSecureTextEntry = true
    $0.autocapitalizationType = .none
  }
  
  private let loginButtton = UIButton().then {
    $0.setTitle("로그인", for: .normal)
    $0.backgroundColor = .systemGray
    $0.layer.cornerRadius = 5
    $0.layer.masksToBounds = true
  }
  
  private let googleLoginButton = UIButton().then {
    $0.setImage(UIImage(named: "ios_light_sq_SI"), for: .normal)
  }
  
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
    self.view.addSubview(self.emailLabel)
    self.view.addSubview(self.emailTextFeild)
    self.view.addSubview(self.passwordLabel)
    self.view.addSubview(self.passwordTextFeild)
    self.view.addSubview(self.loginButtton)
    self.view.addSubview(self.googleLoginButton)
    self.view.addSubview(self.kakaoLoginButton)
    self.view.addSubview(self.signInButton)
    self.view.addSubview(self.skipButton)
  }
  
  private func setupLayout() {
    self.view.flex.direction(.column).define {
      //로그인 입력
      $0.addItem(self.emailLabel).width(Metric.labelWidth).height(Metric.labelHeight).alignSelf(.center).marginTop(200)
      $0.addItem(self.emailTextFeild).width(Metric.textFieldWidth).height(Metric.textFieldHeight).alignSelf(.center)
      $0.addItem(self.passwordLabel).width(Metric.labelWidth).height(Metric.labelHeight).alignSelf(.center)
      $0.addItem(self.passwordTextFeild).width(Metric.textFieldWidth).height(Metric.textFieldHeight).alignSelf(.center)
      
      //로그인 버튼
      $0.addItem(self.loginButtton).width(Metric.buttonWidth).height(Metric.buttonHeight).alignSelf(.center).marginTop(50)
      
      //구글 로그인 버튼
      $0.addItem(self.googleLoginButton)
        .width(Metric.imageButtonWidth)
        .height(Metric.buttonHeight)
        .alignSelf(.center)
        .marginTop(50)
      
      //카카오 로그인 버튼
      $0.addItem(self.kakaoLoginButton)
        .width(Metric.imageButtonWidth)
        .height(Metric.buttonHeight)
        .alignSelf(.center)
        .marginTop(20)
      
      //회원가입 버튼
      $0.addItem(self.signInButton)
        .width(Metric.buttonWidth)
        .height(Metric.buttonHeight)
        .alignSelf(.center)
        .padding(10)
        .marginTop(20)
      
      //로그인 건너뛰기 버튼
      $0.addItem(self.skipButton)
        .width(Metric.buttonWidth)
        .height(Metric.buttonHeight)
        .alignSelf(.center)
        .marginTop(20)
    }
    self.view.flex.layout(mode: .fitContainer)
  }
  
  private func bindAction() {
    self.loginButtton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.login()
      })
      .disposed(by: disposeBag)
    
    self.googleLoginButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.loginGoogle()
      })
      .disposed(by: disposeBag)
    
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
  
  
  private func login() {
    
    guard let email = self.emailTextFeild.text else { return }
    guard let password = self.passwordTextFeild.text else { return }
    
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
      if authResult != nil {
        print("로그인 이메일: ", authResult?.user.email)
        self?.goHome()
      } else {
        print("❗️ 로그인 실패!", error)
        
        let alert = UIAlertController(title: "알림", message: "아이디 혹은 비밀번호가 잘못 입력되었습니다.", preferredStyle: .alert)
        let check = UIAlertAction(title: "확인", style: .destructive, handler: nil)
        alert.addAction(check)
        self?.present(alert, animated: true, completion: nil)
      }
    }
  }
  
  private func loginGoogle() {
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
    
    // Create Google Sign In configuration object.
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
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
}

extension UIViewController {
  func goHome() {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = scene.windows.first else { return }
    
    let tabBar = MainTabBarController()
    window.rootViewController = tabBar
    window.makeKeyAndVisible()
  }
}
