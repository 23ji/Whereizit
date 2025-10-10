//
//  MyPageViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 9/17/25.
//

import FirebaseAuth

import RxSwift

import UIKit

final class MyPageViewController : UIViewController {
  
  private let rootContainer = UIView()
  
  private let disposeBag = DisposeBag()

  var userEmail: String = ""
  
  private let emailLabel = UILabel().then {
    $0.textColor = .black
    $0.font = $0.font.withSize(30)
    $0.textAlignment = .center
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
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    self.userEmail = Auth.auth().currentUser?.email ?? "사용자"
    
    self.addSubviews()
    self.setupLayout()
    self.bindAction()
  }
  
  override func viewDidLayoutSubviews() {
    self.rootContainer.pin.all(self.view.pin.safeArea)
    self.rootContainer.flex.layout()
  }
  
  private func addSubviews() {
    self.view.addSubview(self.rootContainer)
  }
  
  private func setupLayout() {
    self.rootContainer.flex.direction(.column).define {
      $0.addItem(self.emailLabel)
        .grow(1)
        .marginTop(100)
        .alignSelf(.center)
      $0.addItem(self.signOutButton)
        .grow(1)
        .marginTop(100)
        .alignSelf(.center)
    }
    self.emailLabel.text = "\(self.userEmail)님"
  }
  
  
  private func bindAction() {
    self.signOutButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.signOut()
      })
      .disposed(by: disposeBag)
  }
  
  
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
