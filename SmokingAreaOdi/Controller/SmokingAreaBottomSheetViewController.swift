//  SmokingAreaBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 8/31/25.
//

import UIKit
import PanModal

final class SmokingAreaBottomSheetViewController: UIViewController, PanModalPresentable {
  
  private let nameLabel = UILabel().then {
    $0.text = "ddd"
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 16, weight: .bold)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    view.addSubview(nameLabel)
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  // MARK: - PanModalPresentable
  var panScrollable: UIScrollView? { nil }   // 스크롤뷰 없으면 nil
  var shortFormHeight: PanModalHeight { .contentHeight(200) } // 처음 높이
  var longFormHeight: PanModalHeight { .maxHeight } // 위로 끌어올렸을 때 높이
}
