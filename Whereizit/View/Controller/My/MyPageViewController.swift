//
//  MyPageViewController.swift
//  Whereizit
//
//  Created by 이상지 on 9/17/25.
//

import FirebaseAuth
import RxSwift
import Kingfisher
import FlexLayout
import PinLayout
import Then

import UIKit

struct Metric {
  static let profileImageSize: CGFloat = 120
  static let profileImageCornerRadius: CGFloat = 60
  static let emailFontSize: CGFloat = 24
  static let loginPromptFontSize: CGFloat = 20
  static let buttonHeight: CGFloat = 52
  static let buttonCornerRadius: CGFloat = 14
  static let topMarginProfileImage: CGFloat = 60
  static let topMarginEmailLabel: CGFloat = 16
  static let topMarginButtonsStack: CGFloat = 40
  static let signOutTopMargin: CGFloat = 60
  static let loginPromptTopMargin: CGFloat = 200
  static let loginButtonTopMargin: CGFloat = 20
  static let loginButtonWidth: CGFloat = 220
  static let buttonMarginBottom: CGFloat = 16
  static let horizontalPadding: CGFloat = 24
  static let cornerRadius: CGFloat = 12
  static let cardBackgroundColor: UIColor = UIColor.systemGray
}

final class MyPageViewController: UIViewController {
  
  private let rootContainer = UIView()
  private let disposeBag = DisposeBag()
  
  var userEmail: String = ""
  
  
  // MARK: Profile
  
  private let profileImageView = UIImageView().then {
    $0.image = UIImage(systemName: "person.circle.fill")
    $0.tintColor = .systemGray3
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = Metric.profileImageCornerRadius
    $0.clipsToBounds = true
    $0.layer.borderWidth = 2
    $0.layer.borderColor = UIColor.systemGreen.cgColor
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.1
    $0.layer.shadowOffset = CGSize(width: 0, height: 2)
    $0.layer.shadowRadius = 4
  }
  
  private let emailLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .boldSystemFont(ofSize: Metric.emailFontSize)
    $0.textAlignment = .center
  }
  
  
  // MARK: Buttons
  
  private let myAreasButton = UIButton().then {
    $0.setTitle("내가 등록한 구역", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .systemGreen
    $0.layer.cornerRadius = Metric.buttonCornerRadius
    $0.layer.shadowColor = UIColor.systemGreen.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 6
    $0.layer.shadowOpacity = 0.3
  }
  
  private let settingsButton = UIButton().then {
    $0.setTitle("설정", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = Metric.cardBackgroundColor
    $0.layer.cornerRadius = Metric.buttonCornerRadius
    $0.layer.shadowColor = UIColor.systemGray.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 6
    $0.layer.shadowOpacity = 0.3
  }
  
  private let privacyPolicyButton = UIButton().then {
    $0.setTitle("개인정보 처리방침", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = Metric.cardBackgroundColor
    $0.layer.cornerRadius = Metric.buttonCornerRadius
    $0.layer.shadowColor = UIColor.systemGray.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 6
    $0.layer.shadowOpacity = 0.3
  }
  
  private let signOutButton = UIButton().then {
    let title = "로그아웃"
    let attributedString = NSAttributedString(
      string: title,
      attributes: [
        .underlineStyle: NSUnderlineStyle.single.rawValue,
        .foregroundColor: UIColor.gray
      ]
    )
    $0.setAttributedTitle(attributedString, for: .normal)
  }
  
  
  // MARK: Login Prompt
  
  private let loginPromptLabel = UILabel().then {
    $0.text = "로그인을 해주세요"
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: Metric.loginPromptFontSize, weight: .medium)
  }
  
  private let loginButton = UIButton().then {
    $0.setTitle("로그인하러 가기", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    $0.backgroundColor = .systemGreen
    $0.layer.cornerRadius = Metric.cornerRadius
    $0.layer.shadowColor = UIColor.systemGreen.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 8
    $0.layer.shadowOpacity = 0.3
  }
  
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.updateLayoutBasedOnLogin()
    self.addSubviews()
    self.setupProfile()
    self.bindActions()
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.setupProfile()
      self.updateLayoutBasedOnLogin()
  }
  
  
  override func viewDidLayoutSubviews() {
    self.rootContainer.pin.all(self.view.pin.safeArea)
    self.rootContainer.flex.layout()
  }
  
  
  private func updateLayoutBasedOnLogin() {
    self.rootContainer.subviews.forEach { $0.removeFromSuperview() }
    
    self.rootContainer.flex.define { flex in
      if let user = Auth.auth().currentUser {
        self.emailLabel.text = "\(self.userEmail)님"
        
        flex.addItem().direction(.column).paddingHorizontal(Metric.horizontalPadding).define {
          $0.addItem(self.profileImageView)
            .size(Metric.profileImageSize)
            .alignSelf(.center)
            .marginTop(Metric.topMarginProfileImage)
          
          $0.addItem(self.emailLabel)
            .marginTop(Metric.topMarginEmailLabel)
            .alignSelf(.center)
          
          $0.addItem().direction(.column).marginTop(Metric.topMarginButtonsStack).define { flex in
            flex.addItem(self.myAreasButton)
              .height(Metric.buttonHeight)
              .marginBottom(Metric.buttonMarginBottom)
            
            flex.addItem(self.settingsButton)
              .height(Metric.buttonHeight)
              .marginBottom(Metric.buttonMarginBottom)
            
            flex.addItem(self.privacyPolicyButton)
              .height(Metric.buttonHeight)
          }
          
          $0.addItem(self.signOutButton)
            .marginTop(Metric.signOutTopMargin)
            .alignSelf(.center)
        }
      } else {
        flex.addItem(self.loginPromptLabel)
          .marginTop(Metric.loginPromptTopMargin)
          .alignSelf(.center)
        
        flex.addItem(self.loginButton)
          .marginTop(Metric.loginButtonTopMargin)
          .height(Metric.buttonHeight)
          .width(Metric.loginButtonWidth)
          .alignSelf(.center)
      }
    }
    self.rootContainer.flex.layout()
  }
  
  
  private func addSubviews() {
    self.view.addSubview(self.rootContainer)
  }
  
  
  private func setupProfile() {
    self.userEmail = Auth.auth().currentUser?.displayName ?? "사용자"
    if let photoURL = Auth.auth().currentUser?.photoURL {
      self.profileImageView.kf.setImage(with: photoURL)
    } else {
      self.profileImageView.image = UIImage(systemName: "person.circle.fill")
    }
  }
  
  private func bindActions() {
    self.myAreasButton.rx.tap
      .subscribe(onNext: { [weak self] in
        let myAreasVC = MyAreasViewController()
        self?.navigationController?.pushViewController(myAreasVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    self.settingsButton.rx.tap
      .subscribe(onNext: { [weak self] in
        let settingVC = SettingsViewController()
        self?.navigationController?.pushViewController(settingVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    self.privacyPolicyButton.rx.tap
      .subscribe(onNext: { [weak self] in
        let privacyVC = PrivacyPolicyViewController()
        self?.navigationController?.pushViewController(privacyVC, animated: true)
      })
      .disposed(by: disposeBag)

    
    self.signOutButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.signOut()
      })
      .disposed(by: disposeBag)
    
    self.loginButton.rx.tap
      .subscribe(onNext: { [weak self] in
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        self?.present(loginVC, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
    
  // MARK: 로그아웃 처리
  
  private func signOut() {
    let firebaseAuth = Auth.auth()
    do {
      try firebaseAuth.signOut()
      print("로그아웃")
      self.goHome()
    } catch let signOutError as NSError {
      print("Error signing out: %@", signOutError)
    }
  }
}
