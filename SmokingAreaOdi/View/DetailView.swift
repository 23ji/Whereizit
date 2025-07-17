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
    self.addSubview(mapView)

    mapView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
      mapView.heightAnchor.constraint(equalToConstant: 200) // 원하는 높이 고정
    ])
  }
  
  func setMarker() {
    let markerCoordinate = UIImageView(image: UIImage(named: "marker_Pin"))
    
    mapView.addSubview(markerCoordinate)
    
    markerCoordinate.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      markerCoordinate.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
      markerCoordinate.bottomAnchor.constraint(equalTo: self.mapView.centerYAnchor)
    ])
  }
}
