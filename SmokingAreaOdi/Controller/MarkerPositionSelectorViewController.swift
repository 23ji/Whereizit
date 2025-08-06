//
//  MarkerPositionSelectorViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/16/25.
//
import NMapsMap
import PinLayout

import UIKit


class MarkerPositionSelectorViewController: UIViewController, NMFMapViewCameraDelegate {
  
  // MARK: Constant
  
  private enum Metric {
    //static let
  }
  
  //MARK: UI
  
  private let mapView = NMFMapView() // 현재 위치로 초기 로케이션 세팅
  
  //private let addView = AddView()
  let marker = NMFMarker()
  let nextButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setUI()
    self.addSubViews()
    self.configure()
    
    self.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
  }
  
  private func setUI() {
    self.navigationItem.title = "위치 지정"
    
    //카메라 델리게이트 등록해야함
    self.mapView.addCameraDelegate(delegate: self)
    // 마커 기본 속성 (마커는 첫 위치 지정해줘야 나타남)
    marker.position = self.mapView.cameraPosition.target // 카메라 중앙에 마커 첫 위치 지정
    marker.mapView = self.mapView //mapView에 올리기
  }
  
  private func addSubViews() {
    self.view.addSubview(mapView)
    self.view.addSubview(nextButton)
  }
  
  private func configure() {
    self.mapView.pin.all()
    
    self.nextButton.pin
      .width(100)
      .height(56)
      .hCenter()
      .bottom(40)
    
    self.nextButton.setTitle("다음", for: .normal) // 타이틀 설정
    self.nextButton.setTitleColor(.white, for: .normal) // 텍스트 색상 설정
    self.nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    self.nextButton.tintColor = .white
    self.nextButton.backgroundColor = .systemGreen
    self.nextButton.layer.cornerRadius = 28 // 지름 56이라 28이면 완전 원 됨
    self.nextButton.clipsToBounds = true
    //그림자 효과
    self.nextButton.layer.shadowColor = UIColor.black.cgColor
    self.nextButton.layer.shadowOpacity = 0.3
    self.nextButton.layer.shadowOffset = CGSize(width: 0, height: 3)
    self.nextButton.layer.shadowRadius = 4
    
    //    self.markerCoordinateImageView.pin
    //      .size(40)
    //      .center()
    //      .marginTop(-40 / 2) // 마커의 높이 절반을 위로 올려 마커 하단 포인트가 화면 중앙에 배치되도록 설정
  }
  
  @objc private func didTapNextButton() {
    let markerInfoInputVC = MarkerInfoInputViewController()
    navigationController?.pushViewController(markerInfoInputVC, animated: true)
    
    let center = self.mapView.cameraPosition.target
    markerInfoInputVC.lat = center.lat
    markerInfoInputVC.lng = center.lng
  }
}
