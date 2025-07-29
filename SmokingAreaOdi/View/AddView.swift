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
  
  
  // 초기화 메서드 (코드로 UI 작성 시 필수)
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(mapView)
    setupUI()              // UI 구성 메서드 호출
    setMarker()
  }
  
  
  // storyboard 사용할 계획 없기 때문에 fatalError 처리
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.mapView.pin.all()
  }
  
  
  private func setupUI() {
    //지도
//    mapView.pin.all()
//    self.addSubview(mapView)
    
    
    // next 버튼
    self.addSubview(nextButton)
    nextButton.translatesAutoresizingMaskIntoConstraints = false //AutoLayout 위해
    
    NSLayoutConstraint.activate([
      nextButton.widthAnchor.constraint(equalToConstant: 100),
      nextButton.heightAnchor.constraint(equalToConstant: 56),
      nextButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      nextButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -48)
    ])
    
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
  
  func setMarker() {
    let markerCoordinate = UIImageView(image: UIImage(named: "marker_Pin"))
    
    markerCoordinate.translatesAutoresizingMaskIntoConstraints = false
    
    mapView.addSubview(markerCoordinate)
    
    NSLayoutConstraint.activate([
      markerCoordinate.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
      markerCoordinate.bottomAnchor.constraint(equalTo: self.mapView.centerYAnchor)
    ])
  }
}
