//
//  NearbySmokingAreasBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 9/15/25.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class NearbySmokingAreasBottomSheetViewController: UIViewController {
  
  private let rootContainer = UIView()
  
  private let titleLabel = UILabel().then {
    $0.text = "주변 흡연구역 목록"
    $0.font = .systemFont(ofSize: 15, weight: .regular)
    $0.textAlignment = .center
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.view.addSubview(rootContainer)
    self.setupLayout()
  }
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.rootContainer.pin.all()
    self.rootContainer.flex.layout()
  }
  
  
  private func setupLayout() {
    self.rootContainer.flex.justifyContent(.start).marginTop(30)
      .alignItems(.center)
      .define {
        $0.addItem(titleLabel)
      }
  }
}
