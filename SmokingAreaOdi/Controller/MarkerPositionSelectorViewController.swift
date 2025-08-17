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

final class MarkerPositionSelectorViewController: UIViewController, CLLocationManagerDelegate, NMFMapViewCameraDelegate {
  
  // MARK: Constant
  
  private enum Metric {
    static let nextButtonWidth: CGFloat = 100
    static let nextButtonHeight: CGFloat = 56
    static let nextButtonBottom: CGFloat = 40
  }
  
  
  //MARK: UI
  
  private let mapView = NMFMapView()
  private let nextButton = UIButton()
  private let markerCoordinateImageView = UIImageView(image: UIImage(named: "marker_Pin"))
  
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
    self.configure()
    
    self.setLocationManager()
    
    self.diTapNextButton()
  }
  
  
  // MARK: Setup
  
  private func setup() {
    self.navigationItem.title = "위치 지정"
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
      .marginTop(-markerCoordinateImageView.frame.height / 2) // 마커의 높이 절반을 위로 올려 마커 하단 포인트가 화면 중앙에 배치되도록 설정
  }
  
  //Then으로 바꾸기
  private func configure() {
    // 다음 버튼
    self.nextButton.setTitle("다음", for: .normal) // 타이틀 설정
    self.nextButton.setTitleColor(.white, for: .normal) // 텍스트 색상 설정
    self.nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    self.nextButton.tintColor = .white
    self.nextButton.backgroundColor = .systemGreen
    self.nextButton.layer.cornerRadius = Metric.nextButtonHeight / 2 // nextButton의 지름을 반으로 나누면 완전한 원이 됨
    self.nextButton.clipsToBounds = true
    self.nextButton.layer.shadowColor = UIColor.black.cgColor
    self.nextButton.layer.shadowOpacity = 0.3
    self.nextButton.layer.shadowOffset = CGSize(width: 0, height: 3)
    self.nextButton.layer.shadowRadius = 4
    
    // 마커 이미지 뷰
    self.markerCoordinateImageView.layer.shadowColor = UIColor.black.cgColor
    self.markerCoordinateImageView.layer.shadowOpacity = 0.3
    self.markerCoordinateImageView.layer.shadowOffset = CGSize(width: 0, height: 3)
    self.markerCoordinateImageView.layer.shadowRadius = 4
  }
  
  
  // MARK: Location
  
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
    
    cameraUpdate(lat: latitude, lng: longitude)
  }
  
  private func cameraUpdate(lat: Double, lng: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
    self.mapView.moveCamera(cameraUpdate)
  }
  
  
  private func diTapNextButton() {
    self.nextButton.rx.tap.subscribe(onNext: { [weak self] in
      let markerInfoInputVC = MarkerInfoInputViewController()
      self?.navigationController?.pushViewController(markerInfoInputVC, animated: true)
      markerInfoInputVC.markerLat = self?.mapView.cameraPosition.target.lat
      markerInfoInputVC.markerLng = self?.mapView.cameraPosition.target.lng
    })
    .disposed(by: self.disposeBag)
  }
}
