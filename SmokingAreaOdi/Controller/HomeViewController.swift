//
//  HomeViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/14/25.
//
import CoreLocation
import NMapsMap
import SnapKit
import Then

import UIKit


final class HomeViewController: UIViewController, CLLocationManagerDelegate, NMFMapViewCameraDelegate {
  
  // MARK: Constant
  
  private enum Metric {
    static let addButtonSize: CGFloat = 56
    static let addButtonTrailing: CGFloat = 24
    static let addButtonBottom: CGFloat = 40
  }
  
  
  // MARK: UI
  
  private let mapView = NMFNaverMapView() // 현재 위치로 초기 로케이션 세팅
  private let addButton = UIImageView(image: UIImage(named: "plusButton")).then {
    $0.isUserInteractionEnabled = true // 터치 가능하게 꼭 켜야함
  }
  private let locationButton = NMFLocationButton() // 네이버에서 제공하는 위치 버튼
  private var locationManager = CLLocationManager()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Home"

    self.addSubviews()
    self.setLocationManager()
    
    self.makeConstraints()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAddButton))
    addButton.addGestureRecognizer(tapGesture)
  }
  
  
  private func addSubviews() {
    self.view.addSubview(self.mapView)
    self.view.addSubview(self.addButton)
  }
  
  private func setLocationManager() {
    self.mapView.showLocationButton = true

    self.locationManager.delegate = self  // 델리게이트 설정
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest  // 거리 정확도 설정
    // 위치 사용 허용 알림
    self.locationManager.requestWhenInUseAuthorization()
    // 위치 사용을 허용하면 현재 위치 정보를 가져옴
    if CLLocationManager.locationServicesEnabled() {
      self.locationManager.startUpdatingLocation()
    }
    else {
      print("위치 서비스 허용 off")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let location = locations.first {
          print("위치 업데이트!")
          print("위도 : \(location.coordinate.latitude)")
          print("경도 : \(location.coordinate.longitude)")
      }
  }
      
  
  // 위치 가져오기 실패
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("error")
  }
  
  
  private func makeConstraints() {
    self.mapView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    self.addButton.snp.makeConstraints{
      $0.size.equalTo(Metric.addButtonSize)
      $0.trailing.equalToSuperview().inset(Metric.addButtonTrailing)
      $0.bottom.equalToSuperview().inset(Metric.addButtonBottom)
    }
  }
  
  
  // MARK: Configure
  
  @objc private func didTapAddButton() {
    let makerPositionSeletorVC = MarkerPositionSelectorViewController()
    self.navigationController?.pushViewController(makerPositionSeletorVC, animated: true)
  }
}
