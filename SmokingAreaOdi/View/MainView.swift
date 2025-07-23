//
//  MainView.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/14/25.
//
import UIKit
import NMapsMap

import SnapKit


final class MainView: UIView {
  let mapView = NMFMapView()
  let addButton = UIButton()
  
  
  // 초기화 메서드 (코드로 UI 작성 시 필수)
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupMapView()
    setupAddButton()
  }
  
  
  // storyboard 사용할 계획 없기 때문에 fatalError 처리
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: 지도
  
  private func setupMapView() {
    //지도
    addSubview(mapView)
    
    mapView.snp.makeConstraints {
      $0.top.bottom.left.right.equalToSuperview()
    }
  }

  
  // MARK: + 버튼

  private func setupAddButton() {
    
    addSubview(addButton)
    
    addButton.snp.makeConstraints{
      $0.height.width.equalTo(56)
      $0.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview().inset(40)
    }
    
    let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
    let plusImage = UIImage(systemName: "plus", withConfiguration: config)
    addButton.setImage(plusImage, for: .normal)
    addButton.tintColor = .white
    addButton.backgroundColor = .systemGreen
    addButton.layer.cornerRadius = 28 // 지름 56이라 28이면 완전 원 됨
    addButton.clipsToBounds = true
    
    //그림자 효과
    addButton.layer.shadowColor = UIColor.black.cgColor
    addButton.layer.shadowOpacity = 0.3
    addButton.layer.shadowOffset = CGSize(width: 0, height: 3)
    addButton.layer.shadowRadius = 4
  }
}
