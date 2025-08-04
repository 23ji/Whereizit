//
//  MarkerPositionSelectorViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/16/25.
//
import NMapsMap

import UIKit


class MarkerPositionSelectorViewController: UIViewController, NMFMapViewCameraDelegate {
  
  private let addView = AddView()
  let marker = NMFMarker()
  
  override func loadView() {
    view = addView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "위치 지정"
    
    //카메라 델리게이트 등록해야함
    addView.mapView.addCameraDelegate(delegate: self)
    // 마커 기본 속성(특히 첫 위치 지정해줘야 나타남)
    marker.position = addView.mapView.cameraPosition.target // 카메라 중앙에 마커 첫 위치 지정
    marker.mapView = addView.mapView //지도에 올리기
    
    addView.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
  }
  
  @objc private func didTapNextButton() {
    let detailVC = MarkerInfoInputViewController()
    navigationController?.pushViewController(detailVC, animated: true)
    
    let center = addView.mapView.cameraPosition.target
    detailVC.lat = center.lat
    detailVC.lng = center.lng
  }
}
