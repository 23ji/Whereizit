//
//  NearbySmokingAreasBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 9/15/25.
//

import FirebaseCore
import FirebaseStorage
import FlexLayout
import PinLayout
import Then

import UIKit

final class NearbySmokingAreasBottomSheetViewController: UIViewController {
  
  let titleLabel = UILabel().then {
    $0.text = "주변 흡연구역 목록"
    $0.font = .systemFont(ofSize: 20, weight: .bold)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
}
