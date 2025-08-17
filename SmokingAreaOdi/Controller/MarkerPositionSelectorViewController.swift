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


class MarkerPositionSelectorViewController: UIViewController, CLLocationManagerDelegate, NMFMapViewCameraDelegate {
  
  // MARK: Constant
  
  private enum Metric {
    static let nextButtonWidth: CGFloat = 100
    static let nextButtonHeight: CGFloat = 56
    static let nextButtonBottom: CGFloat = 40
  }
  
  
  //MARK: UI
  
  private let mapView = NMFMapView() // 현재 위치로 초기 로케이션 세팅
  private let marker = NMFMarker()
  private let nextButton = UIButton()
  private let markerCoordinateImageView = UIImageView(image: UIImage(named: "marker_Pin"))
  private let locationManager = CLLocationManager()
  
  private var disposeBag = DisposeBag()
  

  //MARK: Properties
  
  var markerLat: Double?
  var markerLng: Double?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setUI()
    self.addSubViews()
    self.setLocationManager()
    self.makeConstraints()
    self.configure()
    self.diTapNextButton()
    print("2. 화면의 중앙 : (\(self.mapView.latitude)   \(self.mapView.longitude))")
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
    self.view.addSubview(markerCoordinateImageView)
  }
  
  
  private func setLocationManager() {
      // 델리게이트를 self(HomeViewController)로 설정
      self.locationManager.delegate = self
      
      // 위치 정확도를 '가장 좋은' 상태로 설정. 이는 배터리 소모가 크지만, 가장 정확한 위치를 제공합니다.
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
      
      // 위치 업데이트를 받기 위해 필요한 최소 거리를 설정.
      // kCLDistanceFilterNone은 위치가 조금만 변경되어도 업데이트를 받게 합니다.
      self.locationManager.distanceFilter = kCLDistanceFilterNone
      
      // '앱 사용 중' 위치 권한을 요청
      self.locationManager.requestWhenInUseAuthorization()
      
      // 위치 업데이트를 시작
      self.locationManager.startUpdatingLocation()
  }

  // CLLocationManagerDelegate
  // 새로운 위치 데이터가 업데이트될 때 호출되는 델리게이트 메서드입니다.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // 1. locations 배열에서 가장 최근 위치 정보 가져오기
    // locations 배열에는 여러 위치 정보가 포함될 수 있으며, 가장 마지막에 있는 요소가 최신 위치입니다.
    // guard let을 사용하여 bestLocation이 nil일 경우 함수를 즉시 종료합니다.
    guard let bestLocation = locations.last else { return }
    
    // 2. 현재 위치의 위도와 경도 추출
    // bestLocation 객체의 coordinate 프로퍼티를 통해 위도(latitude)와 경도(longitude) 값을 추출합니다.
    self.markerLat = bestLocation.coordinate.latitude
    self.markerLng = bestLocation.coordinate.longitude
    
    // 3. 지도 뷰를 현재 위치로 이동시키는 메서드 호출
    // 추출한 위도와 경도 값을 사용하여 지도 카메라를 해당 위치로 이동시킵니다.
    cameraUpdate(lat: self.markerLat!, lng: self.markerLng!)
  }
  
  
  private func cameraUpdate(lat: Double, lng: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
    self.mapView.moveCamera(cameraUpdate)
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
  
  
  private func configure() {
    self.nextButton.setTitle("다음", for: .normal) // 타이틀 설정
    self.nextButton.setTitleColor(.white, for: .normal) // 텍스트 색상 설정
    self.nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    self.nextButton.tintColor = .white
    self.nextButton.backgroundColor = .systemGreen
    self.nextButton.layer.cornerRadius = 28 // nextButtondml지름 56이라 28이면 완전 원 됨
    self.nextButton.clipsToBounds = true
    //nextButton 그림자 효과
    self.nextButton.layer.shadowColor = UIColor.black.cgColor
    self.nextButton.layer.shadowOpacity = 0.3
    self.nextButton.layer.shadowOffset = CGSize(width: 0, height: 3)
    self.nextButton.layer.shadowRadius = 4
    
    //markerCoordinateImageView 그림자 효과
    self.markerCoordinateImageView.layer.shadowColor = UIColor.black.cgColor
    self.markerCoordinateImageView.layer.shadowOpacity = 0.3
    self.markerCoordinateImageView.layer.shadowOffset = CGSize(width: 0, height: 3)
    self.markerCoordinateImageView.layer.shadowRadius = 4
    }
  
  private func diTapNextButton() {
    self.nextButton.rx.tap.subscribe(onNext: { [weak self] in
      let markerInfoInputVC = MarkerInfoInputViewController()
      self?.navigationController?.pushViewController(markerInfoInputVC, animated: true)
      markerInfoInputVC.markerLat = self?.markerLat
      markerInfoInputVC.markerLng = self?.markerLng
    })
    .disposed(by: disposeBag)
  }
}
