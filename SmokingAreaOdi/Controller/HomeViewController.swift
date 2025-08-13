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
  
  //private let mapView = NMFNaverMapView()
  private let mapView = NMFMapView()
  private let addButton = UIImageView(image: UIImage(named: "plusButton")).then {
    $0.isUserInteractionEnabled = true // 터치 가능하게 꼭 켜야함
  }
  private let locationManager = CLLocationManager()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Home"
    
    self.addSubviews()
    self.makeConstraints()
    self.setLocationManager()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAddButton))
    addButton.addGestureRecognizer(tapGesture)
  }
  
  
  private func addSubviews() {
    self.view.addSubview(self.mapView)
    self.view.addSubview(self.addButton)
  }
  
  
  private func setLocationManager() {
    //self.mapView.showLocationButton = true
    
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    self.locationManager.distanceFilter = kCLDistanceFilterNone
    self.locationManager.activityType = .otherNavigation
    self.locationManager.pausesLocationUpdatesAutomatically = false

    let userLocationCoordinate = self.locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 37.5666102, longitude: 126.9783881)
    
    print("1. 사용자의 현재 위치 : \(userLocationCoordinate)")
    
    self.cameraUpdate(lat: userLocationCoordinate.latitude, lng: userLocationCoordinate.longitude)
  }
  
  
  private func cameraUpdate(lat: Double, lng: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
    self.mapView.moveCamera(cameraUpdate)
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
    let markerPositionSeletorVC = MarkerPositionSelectorViewController()
    self.navigationController?.pushViewController(markerPositionSeletorVC, animated: true)
  }
}
