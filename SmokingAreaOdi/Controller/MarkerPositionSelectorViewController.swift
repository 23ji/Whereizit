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
    self.addSubViews()
    self.configure()
    
    self.navigationItem.title = "위치 지정"
    
    //카메라 델리게이트 등록해야함
    self.mapView.addCameraDelegate(delegate: self)
    // 마커 기본 속성(특히 첫 위치 지정해줘야 나타남)
    marker.position = self.mapView.cameraPosition.target // 카메라 중앙에 마커 첫 위치 지정
    marker.mapView = self.mapView //지도에 올리기
    
    self.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
  }
  
  private func addSubViews() {
    self.view.addSubview(mapView)
  }
  
  private func configure() {
    self.mapView.pin.all()
  }
  
  @objc private func didTapNextButton() {
    let markerInfoInputVC = MarkerInfoInputViewController()
    navigationController?.pushViewController(markerInfoInputVC, animated: true)
    
    let center = self.mapView.cameraPosition.target
    markerInfoInputVC.lat = center.lat
    markerInfoInputVC.lng = center.lng
  }
}
