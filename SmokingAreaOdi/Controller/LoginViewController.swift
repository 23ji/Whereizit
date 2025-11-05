//
//  LoginViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 9/16/25.
//

import FlexLayout
import PinLayout
import KakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKAuth
import RxKakaoSDKCommon
import RxKakaoSDKUser
import RxSwift
import Then
import FirebaseAuth
import FirebaseFunctions
import FirebaseCore
import GoogleSignIn

import CryptoKit
import AuthenticationServices

import UIKit


final class LoginViewController: UIViewController {
  
  private enum Metric {
    static let logoSize: CGFloat = 100
    static let iconSize: CGFloat = 20
    static let inputHeight: CGFloat = 52
    static let buttonHeight: CGFloat = 52
    static let cornerRadius: CGFloat = 12
    static let horizontalPadding: CGFloat = 24
  }
  
  private let disposeBag = DisposeBag()
  
  fileprivate var currentNonce: String?

  
  // MARK:  Root Container
  
  private let rootContainer = UIView()
  private let scrollView = UIScrollView()
  private let contentContainer = UIView()
  
  
  // MARK:  Logo Section
  
  private let logoContainer = UIView().then {
    $0.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
    $0.layer.cornerRadius = Metric.logoSize / 2
  }
  
  private let logoImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(named: "marker_Pin_Wind")
    $0.tintColor = .systemGreen
  }
  
  private let appNameLabel = UILabel().then {
    $0.text = "흡구오디?"
    $0.font = .systemFont(ofSize: 32, weight: .bold)
    $0.textColor = .black
    $0.textAlignment = .center
  }
  
  private let subtitleLabel = UILabel().then {
    $0.text = "흡연자와 비흡연자를 위한\n실시간 흡연구역 지도"
    $0.font = .systemFont(ofSize: 14, weight: .regular)
    $0.textColor = .systemGray
    $0.textAlignment = .center
    $0.numberOfLines = 2
  }
  
  
  // MARK:  Email Input
  
  private let emailContainer = UIView().then {
    $0.backgroundColor = UIColor.systemGray6
    $0.layer.cornerRadius = Metric.cornerRadius
  }
  
  private let emailIcon = UIImageView().then {
    $0.image = UIImage(systemName: "envelope.fill")
    $0.tintColor = .systemGray2
    $0.contentMode = .scaleAspectFit
  }
  
  private let emailTextField = UITextField().then {
    $0.placeholder = "이메일"
    $0.autocapitalizationType = .none
    $0.keyboardType = .emailAddress
    $0.font = .systemFont(ofSize: 16)
    $0.textColor = .label
  }
  
  
  // MARK:  Password Input
  
  private let passwordContainer = UIView().then {
    $0.backgroundColor = UIColor.systemGray6
    $0.layer.cornerRadius = Metric.cornerRadius
  }
  
  private let passwordIcon = UIImageView().then {
    $0.image = UIImage(systemName: "lock.fill")
    $0.tintColor = .systemGray2
    $0.contentMode = .scaleAspectFit
  }
  
  private let passwordTextField = UITextField().then {
    $0.placeholder = "비밀번호"
    $0.isSecureTextEntry = true
    $0.autocapitalizationType = .none
    $0.font = .systemFont(ofSize: 16)
    $0.textColor = .label
  }
  
  private let passwordToggleButton = UIButton(type: .custom).then {
    $0.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
    $0.tintColor = .systemGray2
  }
  
  
  // MARK:  Login Button
  
  private let loginButton = UIButton().then {
    $0.setTitle("로그인", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    $0.backgroundColor = .systemGreen
    $0.layer.cornerRadius = Metric.cornerRadius
    $0.layer.shadowColor = UIColor.systemGreen.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 8
    $0.layer.shadowOpacity = 0.3
  }
  
  
  // MARK:  Divider
  
  private let dividerContainer = UIView()
  
  private let leftLine = UIView().then {
    $0.backgroundColor = .systemGray4
  }
  
  private let dividerLabel = UILabel().then {
    $0.text = "또는"
    $0.font = .systemFont(ofSize: 14)
    $0.textColor = .systemGray
    $0.textAlignment = .center
  }
  
  private let rightLine = UIView().then {
    $0.backgroundColor = .systemGray4
  }
  
  
  // MARK:  Social Login Buttons
  
  private let appleButton = UIButton().then {
    $0.setTitle("Apple로 계속하기", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    $0.backgroundColor = .black
    $0.layer.cornerRadius = Metric.cornerRadius
    $0.layer.borderWidth = 1.5
    $0.layer.borderColor = UIColor.black.cgColor
  }
  
  private let appleIcon = UIImageView().then {
    $0.image = UIImage(systemName: "apple.logo")
    $0.tintColor = .white
    $0.contentMode = .scaleAspectFit
  }

  private let googleButton = UIButton().then {
    $0.setTitle("Google로 계속하기", for: .normal)
    $0.setTitleColor(.label, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    $0.backgroundColor = .white
    $0.layer.cornerRadius = Metric.cornerRadius
    $0.layer.borderWidth = 1.5
    $0.layer.borderColor = UIColor.systemGray4.cgColor
  }
  
  private let googleIcon = UIImageView().then {
    $0.image = UIImage(named: "googleLoginButton")
    $0.contentMode = .scaleAspectFit
  }
  
  private let kakaoButton = UIButton().then {
    $0.setTitle("카카오로 계속하기", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    $0.backgroundColor = UIColor(red: 254/255, green: 229/255, blue: 0/255, alpha: 1.0)
    $0.layer.cornerRadius = Metric.cornerRadius
  }
  
//  private let kakaoIcon = UIImageView().then {
//    $0.image = UIImage(systemName: "message.fill") // 실제로는 카카오 아이콘 사용
//    $0.tintColor = .black
//    $0.contentMode = .scaleAspectFit
//  }
  
  
  // MARK:  Bottom Buttons
  
  private let signUpButton = UIButton().then {
    let normalText = "계정이 없으신가요? "
    let boldText = "회원가입"
    
    let attributedString = NSMutableAttributedString(
      string: normalText,
      attributes: [
        .font: UIFont.systemFont(ofSize: 14),
        .foregroundColor: UIColor.systemGray
      ]
    )
    attributedString.append(NSAttributedString(
      string: boldText,
      attributes: [
        .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        .foregroundColor: UIColor.systemGreen
      ]
    ))
    
    $0.setAttributedTitle(attributedString, for: .normal)
  }
  
  private let skipButton = UIButton().then {
    let title = "둘러보기"
    let attributedString = NSAttributedString(
      string: title,
      attributes: [
        .font: UIFont.systemFont(ofSize: 14, weight: .medium),
        .foregroundColor: UIColor.systemGray2
      ]
    )
    $0.setAttributedTitle(attributedString, for: .normal)
  }
  
  
  // MARK:  Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .systemBackground
    
    if let user = Auth.auth().currentUser {
      print(user.email ?? "no email")
      self.goHome()
      return
    }
    
    self.addSubviews()
    self.setupLayout()
    self.bindAction()
    self.setupKeyboardHandling()
    self.setupLogoAnimation()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.layoutViews()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.animateLogoAppearance()
  }
  
  
  // MARK:  Setup
  
  private func addSubviews() {
    self.view.addSubview(self.scrollView)
    self.scrollView.addSubview(self.contentContainer)
    
    // Logo Section
    self.contentContainer.addSubview(self.logoContainer)
    self.logoContainer.addSubview(self.logoImageView)
    self.contentContainer.addSubview(self.appNameLabel)
    self.contentContainer.addSubview(self.subtitleLabel)
    
    // Email Input
    self.contentContainer.addSubview(self.emailContainer)
    self.emailContainer.addSubview(self.emailIcon)
    self.emailContainer.addSubview(self.emailTextField)
    
    // Password Input
    self.contentContainer.addSubview(self.passwordContainer)
    self.passwordContainer.addSubview(self.passwordIcon)
    self.passwordContainer.addSubview(self.passwordTextField)
    self.passwordContainer.addSubview(self.passwordToggleButton)
    
    // Buttons
    self.contentContainer.addSubview(self.loginButton)
    
    // Divider
    self.contentContainer.addSubview(self.dividerContainer)
    self.dividerContainer.addSubview(self.leftLine)
    self.dividerContainer.addSubview(self.dividerLabel)
    self.dividerContainer.addSubview(self.rightLine)
    
    // Social Buttons
    self.contentContainer.addSubview(self.appleButton)
    self.appleButton.addSubview(self.appleIcon)

    self.contentContainer.addSubview(self.googleButton)
    self.googleButton.addSubview(self.googleIcon)
    //self.contentContainer.addSubview(self.kakaoButton)
    //self.kakaoButton.addSubview(self.kakaoIcon)
    
    // Bottom Buttons
    self.contentContainer.addSubview(self.signUpButton)
    self.contentContainer.addSubview(self.skipButton)
  }
  
  private func setupLayout() {
    self.contentContainer.flex.direction(.column).alignItems(.center).paddingHorizontal(Metric.horizontalPadding).define { flex in
      // Logo Section
      flex.addItem(self.logoContainer)
        .width(Metric.logoSize)
        .height(Metric.logoSize)
        .marginTop(30)
      
      flex.addItem(self.appNameLabel)
        .marginTop(16)
      
      flex.addItem(self.subtitleLabel)
        .marginTop(8)
        .marginHorizontal(Metric.horizontalPadding)
      
      // Email Input
      flex.addItem(self.emailContainer)
        .width(100%)
        .height(Metric.inputHeight)
        .marginTop(40)
        .marginHorizontal(Metric.horizontalPadding)
      
      // Password Input
      flex.addItem(self.passwordContainer)
        .width(100%)
        .height(Metric.inputHeight)
        .marginTop(16)
        .marginHorizontal(Metric.horizontalPadding)
      
      // Login Button
      flex.addItem(self.loginButton)
        .width(100%)
        .height(Metric.buttonHeight)
        .marginTop(24)
        .marginHorizontal(Metric.horizontalPadding)
      
      // Divider
      flex.addItem(self.dividerContainer)
        .width(100%)
        .height(20)
        .marginTop(32)
        .marginHorizontal(Metric.horizontalPadding)
      
      // Social Buttons
      flex.addItem(self.appleButton)
          .width(100%)
          .height(Metric.buttonHeight)
          .marginTop(12)
          .marginHorizontal(Metric.horizontalPadding)
      
      flex.addItem(self.googleButton)
        .width(100%)
        .height(Metric.buttonHeight)
        .marginTop(24)
        .marginHorizontal(Metric.horizontalPadding)
      
//      flex.addItem(self.kakaoButton)
//        .width(100%)
//        .height(Metric.buttonHeight)
//        .marginTop(12)
//        .marginHorizontal(Metric.horizontalPadding)
      
      // Sign Up Button
      flex.addItem(self.signUpButton)
        .marginTop(24)
      
      // Skip Button
      flex.addItem(self.skipButton)
        .marginTop(10)
        .marginBottom(40)
    }
  }
  
  private func layoutViews() {
    self.scrollView.pin.all(self.view.pin.safeArea)
    self.contentContainer.pin.top().left().right()
    self.contentContainer.flex.layout(mode: .adjustHeight)
    self.scrollView.contentSize = self.contentContainer.frame.size
    
    // Logo Image Inside Container
    self.logoImageView.pin
      .center()
      .width(60)
      .height(60)
    
    // Email Container Layout
    self.emailIcon.pin
      .left(16)
      .vCenter()
      .width(Metric.iconSize)
      .height(Metric.iconSize)
    
    self.emailTextField.pin
      .after(of: self.emailIcon)
      .marginLeft(12)
      .right(16)
      .vCenter()
      .height(40)
    
    // Password Container Layout
    self.passwordIcon.pin
      .left(16)
      .vCenter()
      .width(Metric.iconSize)
      .height(Metric.iconSize)
    
    self.passwordToggleButton.pin
      .right(16)
      .vCenter()
      .width(24)
      .height(24)
    
    self.passwordTextField.pin
      .after(of: self.passwordIcon)
      .marginLeft(12)
      .before(of: self.passwordToggleButton)
      .marginRight(8)
      .vCenter()
      .height(40)
    
    // Divider Layout
    self.dividerLabel.pin
      .center()
      .sizeToFit()
    
    self.leftLine.pin
      .left()
      .vCenter()
      .before(of: self.dividerLabel)
      .marginRight(12)
      .height(1)
    
    self.rightLine.pin
      .after(of: self.dividerLabel)
      .marginLeft(12)
      .right()
      .vCenter()
      .height(1)
    
    // Social Button Icons
    self.appleIcon.pin
      .left(16)
      .vCenter()
      .width(24)
      .height(24)
    
    self.googleIcon.pin
      .left(16)
      .vCenter()
      .width(24)
      .height(24)
    
//    self.kakaoIcon.pin
//      .left(16)
//      .vCenter()
//      .width(24)
//      .height(24)
  }
  
  private func bindAction() {
    // 로그인 버튼
    self.loginButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.login()
      })
      .disposed(by: disposeBag)
    
    // 애플 로그인
    self.appleButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.startSignInWithAppleFlow()
      })
      .disposed(by: disposeBag)
    
    // 구글 로그인
    self.googleButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.loginGoogle()
      })
      .disposed(by: disposeBag)
    
//    // 카카오 로그인
//    self.kakaoButton.rx.tap
//      .subscribe(onNext: { [weak self] in
//        self?.loginKakao()
//      })
//      .disposed(by: disposeBag)
    
    // 회원가입
    self.signUpButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.signIn()
      })
      .disposed(by: disposeBag)
    
    // 건너뛰기
    self.skipButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.goHome()
      })
      .disposed(by: disposeBag)
    
    // 비밀번호 토글
    self.passwordToggleButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.togglePasswordVisibility()
      })
      .disposed(by: disposeBag)
  }
  
  
  // MARK:  Keyboard Handling
  
  private func setupKeyboardHandling() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    self.view.addGestureRecognizer(tapGesture)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  @objc private func keyboardWillShow(notification: NSNotification) {
    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
    let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
    self.scrollView.contentInset = contentInset
    self.scrollView.scrollIndicatorInsets = contentInset
  }
  
  @objc private func keyboardWillHide(notification: NSNotification) {
    self.scrollView.contentInset = .zero
    self.scrollView.scrollIndicatorInsets = .zero
  }
  
  @objc private func dismissKeyboard() {
    self.view.endEditing(true)
  }
  
  
  // MARK:  Animations
  
  private func setupLogoAnimation() {
    self.logoContainer.alpha = 0
    self.logoContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
  }
  
  private func animateLogoAppearance() {
    UIView.animate(
      withDuration: 0.6,
      delay: 0.1,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 0.5,
      options: .curveEaseOut
    ) {
      self.logoContainer.alpha = 1
      self.logoContainer.transform = .identity
    }
  }
  
  
  // MARK:  Helper Methods
  
  private func togglePasswordVisibility() {
    self.passwordTextField.isSecureTextEntry.toggle()
    let imageName = self.passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
    self.passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
  }
  
  private func showAlert(message: String) {
    let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
    let confirm = UIAlertAction(title: "확인", style: .default)
    alert.addAction(confirm)
    self.present(alert, animated: true)
  }
  
  
  // MARK:  Login Methods
  
  private func login() {
    guard let email = self.emailTextField.text, !email.isEmpty else {
      self.showAlert(message: "이메일을 입력해주세요.")
      return
    }
    
    guard let password = self.passwordTextField.text, !password.isEmpty else {
      self.showAlert(message: "비밀번호를 입력해주세요.")
      return
    }
    
    self.loginButton.isEnabled = false
    self.loginButton.setTitle("로그인 중...", for: .normal)
    
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
      self?.loginButton.isEnabled = true
      self?.loginButton.setTitle("로그인", for: .normal)
      
      if authResult != nil {
        print("✅ 로그인 성공:", authResult?.user.email ?? "")
        self?.goHome()
      } else {
        print("❌ 로그인 실패:", error?.localizedDescription ?? "")
        self?.showAlert(message: "이메일 또는 비밀번호가 올바르지 않습니다.")
      }
    }
  }
  
  private func loginGoogle() {
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
    
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    
    GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
      guard error == nil else {
        print("❌ Google 로그인 실패:", error?.localizedDescription ?? "")
        return
      }
      
      guard let user = result?.user,
            let idToken = user.idToken?.tokenString else {
        print("❌ Google 사용자 정보 없음")
        return
      }
      
      let credential = GoogleAuthProvider.credential(
        withIDToken: idToken,
        accessToken: user.accessToken.tokenString
      )
      
      Auth.auth().signIn(with: credential) { authResult, error in
        if let error = error {
          print("❌ Firebase 구글 로그인 실패:", error.localizedDescription)
          return
        }
        
        if let user = authResult?.user {
          print("✅ Firebase 로그인 성공:", user.email ?? "")
          self.goHome()
        }
      }
    }
  }
  
  /*
  private func loginKakao() {
    let functions = Functions.functions(region: "us-central1")
    
    if UserApi.isKakaoTalkLoginAvailable() {
      UserApi.shared.rx.loginWithKakaoTalk()
        .subscribe(onNext: { oauthToken in
          self.handleKakaoToken(oauthToken.accessToken, functions: functions)
        }, onError: { error in
          print("❌ 카카오톡 로그인 에러:", error.localizedDescription)
        })
        .disposed(by: disposeBag)
    } else {
      UserApi.shared.rx.loginWithKakaoAccount()
        .subscribe(onNext: { oauthToken in
          self.handleKakaoToken(oauthToken.accessToken, functions: functions)
        }, onError: { error in
          print("❌ 카카오 계정 로그인 에러:", error.localizedDescription)
        })
        .disposed(by: disposeBag)
    }
  }
  
  private func handleKakaoToken(_ token: String, functions: Functions) {
    print("카카오 토큰:", token)
    
    let callable = functions.httpsCallable("kakaoLogin")
    callable.call(["accessToken": token]) { result, error in
      if let error = error as NSError? {
        print("❌ Firebase Function 호출 에러:", error.localizedDescription)
        return
      }
      
      if let customToken = (result?.data as? [String: Any])?["token"] as? String {
        Auth.auth().signIn(withCustomToken: customToken) { authResult, error in
          if let user = authResult?.user {
            print("✅ Firebase 로그인 성공: \(user.uid)")
            self.goHome()
          } else if let error = error {
            print("❌ Firebase 커스텀 토큰 로그인 에러:", error.localizedDescription)
          }
        }
      }
    }
  }
  */
  
  private func signIn() {
    let signInVC = SignInViewController()
    self.present(signInVC, animated: true)
  }
}





// MARK:  Apple Login
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  
  func startSignInWithAppleFlow() {
    let nonce = randomNonceString()
    currentNonce = nonce
    let request = ASAuthorizationAppleIDProvider().createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce)
    
    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = self
    controller.presentationContextProvider = self
    controller.performRequests()
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
    guard let nonce = currentNonce else {
      print("Invalid state: No login request was sent.")
      return
    }
    guard let appleIDToken = appleIDCredential.identityToken,
          let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
      print("Unable to fetch identity token.")
      return
    }
    
    // ✅ 최신 Firebase 방식
    let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                    rawNonce: nonce,
                                                    fullName: appleIDCredential.fullName)
    
    Auth.auth().signIn(with: credential) { [weak self] authResult, error in
      if let error = error {
        print("Error during Firebase sign-in: \(error.localizedDescription)")
        return
      }
      print("✅ Apple login success: \(authResult?.user.uid ?? "")")
      self?.goHome()
    }
  }
  
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return view.window!
  }
  
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap { String(format: "%02x", $0) }.joined()
  }
  
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
      let randoms = (0 ..< 16).map { _ in UInt8.random(in: 0...255) }
      randoms.forEach { random in
        if remainingLength == 0 { return }
        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }
    return result
  }
}


// MARK:  Extension

extension UIViewController {
  func goHome() {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = scene.windows.first else { return }
    
    let tabBar = MainTabBarController()
    window.rootViewController = tabBar
    window.makeKeyAndVisible()
  }
}
