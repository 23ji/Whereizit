//
//  MyPageViewContoller.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 9/17/25.
//

import UIKit

final class MyPageViewContoller : UIViewController {
  
  let userName: String = "홍길동"
  
  private let nameLabel = UILabel().then {
    $0.textColor = .black
    $0.font = $0.font.withSize(30)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.addSubviews()
    self.setupLayout()
  }
  
  private func addSubviews() {
    self.view.addSubview(self.nameLabel)
  }
  
  private func setupLayout() {
      self.view.flex.direction(.column).define {
          $0.addItem(self.nameLabel)
              .width(200)
              .height(50)
              .marginTop(100)
              .alignSelf(.center)
      }
      self.nameLabel.text = "\(self.userName)님"
      self.view.flex.layout(mode: .fitContainer)
  }
}
