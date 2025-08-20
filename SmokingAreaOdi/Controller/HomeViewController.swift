//
//  HomeViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/14/25.
//

import CoreLocation
import NMapsMap
import RxSwift
import RxCocoa
import SnapKit
import Then

import UIKit


final class HomeViewController: UIViewController {
  
  // MARK: Constant
  
  private enum Metric {
    static let addButtonTrailing: CGFloat = 24
    static let addButtonBottom: CGFloat = 40
  }
  
  
  // MARK: UI
  
  private let mapView = NMFMapView()
  private let addButton = UIButton().then {
    $0.setImage(UIImage(named: "plusButton"), for: .normal)
  }
  
  // MARK: Property
  
  private let locationManager = CLLocationManager()
  
  private let disposeBag = DisposeBag()
  
  
  // MARK: LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.addSubviews()
    self.makeConstraints()
    
    self.setLocationManager()
    
    self.didTapAddButton()
  }
  
  
  // MARK: Setup
  
  private func setup() { self.navigationItem.title = "Home" } //한 줄로 가능하면 한 줄로
  
  private func addSubviews() {
    self.view.addSubview(self.mapView)
    self.view.addSubview(self.addButton)
  }
  
  private func makeConstraints() {
    self.mapView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    self.addButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(Metric.addButtonTrailing)
      $0.bottom.equalToSuperview().inset(Metric.addButtonBottom)
    }
  }
  
  
  // MARK: Location
  
  private func setLocationManager() {
    // CLLocationManagerDelegate를 self(HomeViewController)로 설정합니다.
    // 이는 위치 정보가 업데이트되었을 때 locationManager(_:didUpdateLocations:)와 같은 델리게이트 메서드를 호출하게 합니다.
    self.locationManager.delegate = self
    
    // 위치 정확도를 '내비게이션에 최적인 정확도'로 설정합니다.
    // 이는 가장 높은 정확도를 요구하며, 배터리 소모가 상대적으로 큽니다.
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    
    // 위치 업데이트를 받기 위해 필요한 최소 거리를 설정합니다.
    // kCLDistanceFilterNone은 위치가 조금만 변경되어도 업데이트를 받겠다는 의미입니다.
    self.locationManager.distanceFilter = kCLDistanceFilterNone
    
    // 앱의 활동 유형을 '다른 내비게이션'으로 설정합니다.
    // 이는 위치 업데이트가 어떤 용도로 사용되는지 iOS에 알려주어 시스템이 배터리 소모를 최적화하도록 돕습니다.
    // 자전거, 스쿠터, 기차, 보트, 오프로드 차량 등 도로를 따르지 않거나 따르지 않을 수 있는 활동에 대한 위치를 나타내는 값입니다.
    self.locationManager.activityType = .otherNavigation
    
    // 위치 업데이트가 일시적으로 중단될 수 있는지 여부를 설정합니다.
    // false로 설정하면 사용자가 움직이지 않더라도 위치 업데이트를 중단하지 않습니다.
    self.locationManager.pausesLocationUpdatesAutomatically = false
    
    // 사용자에게 '앱 사용 중' 위치 권한을 요청하는 알림창을 띄웁니다.
    // 이 메서드를 호출하기 전에 Info.plist에 'Privacy - Location When In Use Usage Description' 키를 추가해야 합니다.
    self.locationManager.requestWhenInUseAuthorization()
    
    // 위치 업데이트를 시작합니다.
    // 이 시점부터 위치가 변경될 때마다 locationManager(_:didUpdateLocations:) 델리게이트 메서드가 호출됩니다.
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
    let userLat = bestLocation.coordinate.latitude
    let userLng = bestLocation.coordinate.longitude
    
    print("1. 사용자의 위치 : (\(userLat), \(userLng))")
    
    // 3. 지도 뷰를 현재 위치로 이동시키는 메서드 호출
    // 추출한 위도와 경도 값을 사용하여 지도 카메라를 해당 위치로 이동시킵니다.
    cameraUpdate(lat: userLat, lng: userLng)
  }
  
  
  private func cameraUpdate(lat: Double, lng: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
    self.mapView.moveCamera(cameraUpdate)
  }
  
  
  private func didTapAddButton() {
    self.addButton.rx.tap.subscribe(onNext : { [weak self] in
      let markerPositionSeletorVC = MarkerPositionSelectorViewController()
      self?.navigationController?.pushViewController(markerPositionSeletorVC, animated: true)
    })
    .disposed(by: self.disposeBag)
  }
}

//extension으로 관련 코드들 분리하기
extension HomeViewController: CLLocationManagerDelegate {
  
}

extension HomeViewController: NMFMapViewCameraDelegate {
  
}
