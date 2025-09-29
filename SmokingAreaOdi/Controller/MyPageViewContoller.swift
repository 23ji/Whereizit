//
//  MyPageViewContoller.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 9/17/25.
//

import UIKit

final class MyPageViewContoller : UIViewController {
  
  private let nameLabel = UILabel().then {
    $0.text = "ddd"
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
      $0.addItem(self.nameLabel).width(200).height(50).margin(100)
    }
    self.view.flex.layout(mode: .fitContainer)
  }
}
