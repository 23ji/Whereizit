//
//  SmokingAreaBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 8/31/25.
//

import Then

import UIKit

final class SmokingAreaBottomSheetViewController: UIViewController {
    
  let areaName = UILabel()
    
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setUI()
    self.addSubviews()
    self.setConstraint()
  }
  
  private func setUI() {
    self.view.backgroundColor = .white
  }
  
  private func addSubviews() {
    self.view.addSubview(self.areaName)
  }
  
  private func setConstraint() {
    self.areaName.pin.width(100).height(20).top(10).left(10)
  }
}
