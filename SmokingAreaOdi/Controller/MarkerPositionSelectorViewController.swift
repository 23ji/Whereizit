//
//  MarkerPositionSelectorViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/16/25.
//

import NMapsMap
import PinLayout
import Then
import RxCocoa
import RxSwift

import UIKit

final class MarkerPositionSelectorViewController: UIViewController {
  
  // MARK: Constant
  
  private enum Metric {
    static let nextButtonWidth: CGFloat = 100
    static let nextButtonHeight: CGFloat = 56
    static let nextButtonBottom: CGFloat = 40
  }
  
  
  //MARK: UI
  
  private let mapView = NMFNaverMapView()
  
  private let nextButton = UIButton().then {
    $0.setTitle("다음", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    $0.tintColor = .white
    $0.backgroundColor = .systemGreen
    $0.layer.cornerRadius = Metric.nextButtonHeight / 2 // nextButton의 지름을 반으로 나누면 완전한 원이 됨
    $0.clipsToBounds = true
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.3
    $0.layer.shadowOffset = CGSize(width: 0, height: 3)
    $0.layer.shadowRadius = 4
  }
  
  private let markerCoordinateImageView = UIImageView(image: UIImage(named: "marker_Pin")).then {
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.3
    $0.layer.shadowOffset = CGSize(width: 0, height: 3)
    $0.layer.shadowRadius = 4
  }
  
  private let closeButton = UIButton().then {
    $0.setImage(UIImage(systemName: "xmark"), for: .normal)
    $0.tintColor = .black
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 20
    $0.layer.shadowOpacity = 0.1
  }
  
  private let locationManager = CLLocationManager()
  
  private var disposeBag = DisposeBag()
  
  
  //MARK: Properties
  
  var markerLat: Double?
  var markerLng: Double?
  
  
  //MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.addSubViews()
    self.makeConstraints()
    self.setupCloseButton()
    
    self.setLocationManager()
    
    self.diTappedNextButton()
  }
  
  
  // MARK: Setup
  
  private func setup() {
    self.mapView.showLocationButton = true
    self.mapView.mapView.zoomLevel = 16.0
    
    guard let navBar = self.navigationController?.navigationBar else { return }
    let appearance   = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .white
    
    navBar.standardAppearance = appearance
    navBar.scrollEdgeAppearance = appearance
  }
  
  private func addSubViews() {
    self.view.addSubview(self.mapView)
    self.view.addSubview(self.nextButton)
    self.view.addSubview(self.markerCoordinateImageView)
  }
  
  private func makeConstraints() {
    self.mapView.pin.all()
    
    self.nextButton.pin
      .width(Metric.nextButtonWidth)
      .height(Metric.nextButtonHeight)
      .bottom(Metric.nextButtonBottom)
      .hCenter()
    
    self.markerCoordinateImageView.pin
      .center()
      .marginTop(-markerCoordinateImageView.frame.height / 2)
    // 마커의 높이 절반을 위로 올려 마커 하단 포인트가 화면 중앙에 배치되도록 설정
  }
  
  
  private func setupCloseButton() {
    view.addSubview(closeButton)
    closeButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      $0.trailing.equalToSuperview().inset(16)
      $0.width.height.equalTo(40)
    }
    
    closeButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.dismiss(animated: true) // 모달 닫기
      })
      .disposed(by: disposeBag)
  }
  
  
  private func diTappedNextButton() {
    self.nextButton.rx.tap.subscribe(
      onNext: { [weak self] in
        let markerInfoInputVC = MarkerInfoInputViewController()
        markerInfoInputVC.markerLat = self?.mapView.mapView.cameraPosition.target.lat
        markerInfoInputVC.markerLng = self?.mapView.mapView.cameraPosition.target.lng
        self?.present(markerInfoInputVC, animated: true)
      })
    .disposed(by: self.disposeBag)
  }
}


// MARK: Location

extension MarkerPositionSelectorViewController : CLLocationManagerDelegate {
  private func setLocationManager() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    self.locationManager.distanceFilter = kCLDistanceFilterNone
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let bestLocation = locations.last else { return }
    
    let latitude = bestLocation.coordinate.latitude
    let longitude = bestLocation.coordinate.longitude
    
    print("2. 사용자의 좌표 : (\(latitude), \(longitude))")
    
    self.cameraUpdate(lat: latitude, lng: longitude)
    manager.stopUpdatingLocation()
  }
  
  private func cameraUpdate(lat: Double, lng: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
    self.mapView.mapView.moveCamera(cameraUpdate)
  }
}
