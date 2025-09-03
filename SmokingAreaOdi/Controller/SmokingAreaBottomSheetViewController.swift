//
//  SmokingAreaBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 8/31/25.
//

import FlexLayout
import PinLayout
import Then

import UIKit

final class SmokingAreaBottomSheetViewController: UIViewController {
  
  // MARK:  UI Components
  
  private let rootFlexContainer = UIView()
  
  private let areaImageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
    $0.layer.cornerRadius = 8
    $0.clipsToBounds = true
  }
  
  private let nameLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 18, weight: .bold)
    $0.numberOfLines = 0
    $0.text = "장소 이름"
  }
  
  private let descriptionLabel = UILabel().then {
    $0.textColor = .systemGray
    $0.font = .systemFont(ofSize: 14)
    $0.numberOfLines = 0
    $0.text = "장소에 대한 설명입니다."
  }
  
  
  // MARK:  LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    self.view.addSubview(self.rootFlexContainer)
    self.setupLayout()
  }
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.rootFlexContainer.pin.all(self.view.pin.safeArea)
    self.rootFlexContainer.flex.layout()
  }
  
  
  // MARK:  Setup Layout
  
  private func setupLayout() {
    rootFlexContainer.flex.direction(.column).padding(20).define { flex in
      flex.addItem().direction(.row).alignItems(.center).define { flex in
        flex.addItem(self.areaImageView)
          .width(100)
          .height(100)
        
        flex.addItem()
          .direction(.column)
          .marginLeft(16)
          .grow(1)        // 남은 너비를 모두 차지 (늘어나기)
          .shrink(1)      // 핵심: 공간이 부족하면 수축하기
          .define {
            $0.addItem(self.nameLabel)
            $0.addItem(self.descriptionLabel).marginTop(4)
          }
      }
    }
  }
  
  
  // MARK:  Public Method
  
  public func configure(with data: SmokingArea) {
    DispatchQueue.main.async {
      self.nameLabel.text = data.name
      self.descriptionLabel.text = data.description
      
      self.rootFlexContainer.flex.markDirty()
      self.view.setNeedsLayout()
    }
  }
}

