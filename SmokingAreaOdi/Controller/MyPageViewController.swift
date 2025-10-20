//
//  MyPageViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 9/17/25.
//

import FirebaseAuth
import RxSwift

import UIKit

final class MyPageViewController: UIViewController {
  
  private let rootContainer = UIView()
  
  private let disposeBag = DisposeBag()
  
  var userEmail: String = ""
  
  private let emailLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .boldSystemFont(ofSize: 24)
    $0.textAlignment = .center
  }
  
  // MARK:  마이페이지 메뉴 버튼들
  
  private let mySmokingAreasButton = UIButton().then {
    $0.setTitle("내가 등록한 흡연구역", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .systemGreen
    $0.layer.cornerRadius = 10
  }
  
  private let myCommentsButton = UIButton().then {
    $0.setTitle("내가 단 댓글", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .systemGreen
    $0.layer.cornerRadius = 10
  }
  
  private let favoritesButton = UIButton().then {
    $0.setTitle("즐겨찾기한 구역", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .systemGreen
    $0.layer.cornerRadius = 10
  }
  
  private let settingsButton = UIButton().then {
    $0.setTitle("설정", for: .normal)
    $0.setTitleColor(.darkGray, for: .normal)
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.cornerRadius = 10
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
  
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.userEmail = Auth.auth().currentUser?.email ?? "사용자"
    self.bindActions()
    self.addSubviews()
    self.setupLayout()
  }
  
  override func viewDidLayoutSubviews() {
    self.rootContainer.pin.all(self.view.pin.safeArea)
    self.rootContainer.flex.layout()
  }
  
  
  private func bindActions() {
    self.mySmokingAreasButton.rx.tap
      .subscribe(onNext: { [weak self] in
        let mySmokingAreasVC = MySmokingAreasViewController()
        self?.navigationController?.pushViewController(mySmokingAreasVC, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  
  // MARK:  UI
  
  private func addSubviews() {
    self.view.addSubview(self.rootContainer)
  }
  
  private func setupLayout() {
    self.emailLabel.text = "\(self.userEmail)님"
    
    self.rootContainer.flex.direction(.column).paddingHorizontal(24).define {
      $0.addItem(self.emailLabel)
        .marginTop(60)
        .alignSelf(.center)
      
      $0.addItem().direction(.column).marginTop(60).define {
        $0.addItem(self.mySmokingAreasButton).height(50).marginBottom(16)
        $0.addItem(self.myCommentsButton).height(50).marginBottom(16)
        $0.addItem(self.favoritesButton).height(50).marginBottom(16)
        $0.addItem(self.settingsButton).height(50)
      }
      
      $0.addItem(self.signOutButton)
        .marginTop(100)
        .alignSelf(.center)
    }
  }
  
  
  // MARK:  로그아웃 처리
  
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
