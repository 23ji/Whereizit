//
//  MyPageViewContoller.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 9/17/25.
//

import UIKit

final class MyPageViewContoller : UIViewController {
  
  private let rootContainer = UIView()
  
  let userName: String = "홍길동"
  
  private let nameLabel = UILabel().then {
    $0.textColor = .black
    $0.font = $0.font.withSize(30)
    $0.textAlignment = .center
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.addSubviews()
    self.setupLayout()
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
          $0.addItem(self.nameLabel)
              .width(200)
              .height(50)
              .marginTop(100)
              .alignSelf(.center)
      }
      self.nameLabel.text = "\(self.userName)님"
  }
}
