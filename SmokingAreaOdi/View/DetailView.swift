//
//  DetailView.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/17/25.
//
import NMapsMap
import UIKit

final class DetailView: UIView {
  let mapView = NMFMapView()
  let addButton = UIButton()

  
  // 초기화 메서드 (코드로 UI 작성 시 필수)
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()              // UI 구성 메서드 호출
    setMarker()
  }
  
  
  // storyboard 사용할 계획 없기 때문에 fatalError 처리
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    //지도
    mapView.frame = bounds
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight] //크기 자동 조절
    addSubview(mapView)
    
    addSubview(addButton)
    addButton.translatesAutoresizingMaskIntoConstraints = false //AutoLayout 위해
    
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
