//
//  SignInViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 9/18/25.
//

import FirebaseAuth

import FlexLayout
import PinLayout
import Then

import RxSwift

import UIKit

final class SignInViewController: UIViewController {
  
  private enum Metric {
    static let logoSize: CGFloat = 100
    static let iconSize: CGFloat = 20
    static let inputHeight: CGFloat = 52
    static let buttonHeight: CGFloat = 52
    static let cornerRadius: CGFloat = 12
    static let horizontalPadding: CGFloat = 24
  }
  
  private let disposeBag = DisposeBag()
  
  // MARK: Root Container
  private let rootContainer = UIView()
  private let scrollView = UIScrollView()
  private let contentContainer = UIView()
  
  // MARK: Logo Section
  private let logoContainer = UIView().then {
    $0.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
    $0.layer.cornerRadius = Metric.logoSize / 2
  }
  
  private let logoImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(named: "marker_Pin")
    $0.tintColor = .systemGreen
  }
  
  private let appNameLabel = UILabel().then {
    $0.text = "흡구오디?"
    $0.font = .systemFont(ofSize: 32, weight: .bold)
    $0.textColor = .black
    $0.textAlignment = .center
  }
  
  private let subtitleLabel = UILabel().then {
    $0.text = "회원가입 후 실시간 흡연구역을 확인해보세요"
    $0.font = .systemFont(ofSize: 14)
    $0.textColor = .systemGray
    $0.textAlignment = .center
    $0.numberOfLines = 2
  }
  
  // MARK: Email Input
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
  
  // MARK: Password Input
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
  
  // MARK: Sign Up Button
  private let signUpButton = UIButton().then {
    $0.setTitle("회원가입", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    $0.backgroundColor = .systemGreen
    $0.layer.cornerRadius = Metric.cornerRadius
  }
  
  // MARK: Bottom Button
  private let loginButton = UIButton().then {
    let normalText = "이미 계정이 있으신가요? "
    let boldText = "로그인"
    
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
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .systemBackground
    
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
  
  // MARK: Setup
  private func addSubviews() {
    self.view.addSubview(self.scrollView)
    self.scrollView.addSubview(self.contentContainer)
    
    self.contentContainer.addSubview(self.logoContainer)
    self.logoContainer.addSubview(self.logoImageView)
    self.contentContainer.addSubview(self.appNameLabel)
    self.contentContainer.addSubview(self.subtitleLabel)
    
    self.contentContainer.addSubview(self.emailContainer)
    self.emailContainer.addSubview(self.emailIcon)
    self.emailContainer.addSubview(self.emailTextField)
    
    self.contentContainer.addSubview(self.passwordContainer)
    self.passwordContainer.addSubview(self.passwordIcon)
    self.passwordContainer.addSubview(self.passwordTextField)
    self.passwordContainer.addSubview(self.passwordToggleButton)
    
    self.contentContainer.addSubview(self.signUpButton)
    self.contentContainer.addSubview(self.loginButton)
  }
  
  private func setupLayout() {
    self.contentContainer.flex.direction(.column).alignItems(.center).paddingHorizontal(Metric.horizontalPadding).define {
      $0.addItem(self.logoContainer)
        .width(Metric.logoSize)
        .height(Metric.logoSize)
        .marginTop(60)
      
      $0.addItem(self.appNameLabel)
        .marginTop(16)
      
      $0.addItem(self.subtitleLabel)
        .marginTop(8)
        .marginHorizontal(Metric.horizontalPadding)
      
      $0.addItem(self.emailContainer)
        .width(100%)
        .height(Metric.inputHeight)
        .marginTop(40)
      
      $0.addItem(self.passwordContainer)
        .width(100%)
        .height(Metric.inputHeight)
        .marginTop(16)
      
      $0.addItem(self.signUpButton)
        .width(100%)
        .height(Metric.buttonHeight)
        .marginTop(24)
      
      $0.addItem(self.loginButton)
        .marginTop(16)
        .marginBottom(40)
    }
  }
  
  private func layoutViews() {
    self.scrollView.pin.all(view.pin.safeArea)
    self.contentContainer.pin.top().left().right()
    self.contentContainer.flex.layout(mode: .adjustHeight)
    self.scrollView.contentSize = contentContainer.frame.size
    
    self.logoImageView.pin.center().width(60).height(60)
    
    self.emailIcon.pin.left(16).vCenter().width(Metric.iconSize).height(Metric.iconSize)
    self.emailTextField.pin.after(of: emailIcon).marginLeft(12).right(16).vCenter().height(40)
    
    self.passwordIcon.pin.left(16).vCenter().width(Metric.iconSize).height(Metric.iconSize)
    self.passwordToggleButton.pin.right(16).vCenter().width(24).height(24)
    self.passwordTextField.pin.after(of: passwordIcon).marginLeft(12).before(of: passwordToggleButton).marginRight(8).vCenter().height(40)
  }
  
  private func bindAction() {
    self.signUpButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.signUp()
      })
      .disposed(by: disposeBag)
    
    self.loginButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    self.passwordToggleButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.togglePasswordVisibility()
      })
      .disposed(by: disposeBag)
  }
  
  private func setupKeyboardHandling() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tapGesture)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    view.endEditing(true)
  }
  
  private func setupLogoAnimation() {
    self.logoContainer.alpha = 0
    self.logoContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
  }
  
  private func animateLogoAppearance() {
    UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
      self.logoContainer.alpha = 1
      self.logoContainer.transform = .identity
    }
  }
  
  private func togglePasswordVisibility() {
    self.passwordTextField.isSecureTextEntry.toggle()
    let imageName = self.passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
    self.passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
  }
  
  private func signUp() {
    guard let email = self.emailTextField.text, !email.isEmpty,
          let password = self.passwordTextField.text, !password.isEmpty else { return }
    
    Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
      if let error = error {
        print("❌ 회원가입 실패:", error.localizedDescription)
      } else {
        print("✅ 회원가입 성공:", authResult?.user.email ?? "")
        self?.goHome()
      }
    }
  }
}
