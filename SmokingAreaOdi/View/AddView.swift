//
//  AddView.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/16/25.
//
import NMapsMap
import UIKit

import PinLayout


final class AddView: UIView {
  let mapView = NMFMapView()
  let nextButton = UIButton()
  let markerCoordinate = UIImageView(image: UIImage(named: "marker_Pin"))
  
  
  // 초기화 메서드 (코드로 UI 작성 시 필수)
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(mapView)
    addSubview(nextButton)
    addSubview(markerCoordinate)
    setupUI()              // UI 구성 메서드 호출
    //setMarker()
  }
  
  
  // storyboard 사용할 계획 없기 때문에 fatalError 처리
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.mapView.pin
      .all()
    
    self.nextButton.pin
      .horizontally(100)
      .height(56)
      .bottom(safeAreaInsets.bottom + 24)
    
    
    let markerSize = markerCoordinate.image?.size ?? CGSize(width: 40, height: 40)
    
    self.markerCoordinate.pin
      .size(markerSize)
      .center()
      .marginTop(-markerSize.height / 2) //이미지의 높이 절반을 위로 올려 이미지의 하단이 정중앙에 오도록
  }
  
  
  private func setupUI() {
    nextButton.setTitle("다음", for: .normal) // 타이틀 설정
    nextButton.setTitleColor(.white, for: .normal) // 텍스트 색상 설정
    nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    nextButton.tintColor = .white
    nextButton.backgroundColor = .systemGreen
    nextButton.layer.cornerRadius = 28 // 지름 56이라 28이면 완전 원 됨
    nextButton.clipsToBounds = true
    
    //그림자 효과
    nextButton.layer.shadowColor = UIColor.black.cgColor
    nextButton.layer.shadowOpacity = 0.3
    nextButton.layer.shadowOffset = CGSize(width: 0, height: 3)
    nextButton.layer.shadowRadius = 4
  }
}
