//
//  HomeViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/14/25.
//

import CoreLocation
import FirebaseCore
import FirebaseFirestore
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
  
  private let mapView = NMFNaverMapView()
  private let addButton = UIButton().then {
    $0.setImage(UIImage(named: "plusButton"), for: .normal)
  }
  
  // MARK: Property
  
  private let db = Firestore.firestore()
  
  private let locationManager = CLLocationManager()
  
  private let disposeBag = DisposeBag()
  
  
  // MARK: LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.addSubviews()
    self.makeConstraints()
    
    self.setLocationManager()
    
    self.didTappedAddButton()
    self.smokingAreas()
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
  
  
  // MARK: Action
  
  private func didTappedAddButton() {
    self.addButton.rx.tap.subscribe(
      onNext : { [weak self] in
        let markerPositionSeletorVC = MarkerPositionSelectorViewController()
        self?.navigationController?.pushViewController(markerPositionSeletorVC, animated: true)
      })
    .disposed(by: self.disposeBag)
  }
  
  
  // MARK: Area Marker
  
  private func smokingAreas() {
    db.collection("smokingAreas").addSnapshotListener { snapshot, error in
      guard let snapshot = snapshot else { return }
      for doc in snapshot.documents {
        let data = doc.data()
        guard let name = data["name"] as? String else { return }
        guard let description = data["description"] as? String else { return }
        guard let areaLat = data["areaLat"] as? Double else { return }
        guard let areaLng = data["areaLng"] as? Double else { return }
        
        let areaMarker = NMFMarker()
        areaMarker.iconImage = NMFOverlayImage(name: "marker_Pin")
        areaMarker.position = NMGLatLng(lat: areaLat, lng: areaLng)
        areaMarker.mapView = self.mapView.mapView
      }
    }
  }

  
  private func showMyViewControllerInACustomizedSheet() {
    let viewControllerToPresent = SmokingAreaBottomSheetViewController()
    if let sheet = viewControllerToPresent.sheetPresentationController {
      let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("thirtyPercent")) { context in
        return context.maximumDetentValue * 0.3
      }
      
      sheet.detents = [customDetent, .large()]
      sheet.selectedDetentIdentifier = .init("thirtyPercent") // 처음 뜰 때 30%로
      sheet.largestUndimmedDetentIdentifier = .large
      sheet.prefersScrollingExpandsWhenScrolledToEdge = false
      sheet.prefersEdgeAttachedInCompactHeight = true
      sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
    }
    present(viewControllerToPresent, animated: true, completion: nil)
  }
}


// MARK: Location / Camera
// 위치 업데이트 시 최신 좌표로 카메라 이동
extension HomeViewController: CLLocationManagerDelegate {
  
  private func setLocationManager() {
    self.locationManager.delegate = self // 위치 정보 업데이트 시 델리게이트 호출
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // 최고 수준 정확도
    self.locationManager.distanceFilter = kCLDistanceFilterNone // 조금 변경되어도 위치 업데이트
    self.locationManager.activityType = .otherNavigation // 도로 따르지 않는 수준의 사용자
    self.locationManager.pausesLocationUpdatesAutomatically = false // 사용자가 움직이지 않아도 위치 업데이트
    self.locationManager.requestWhenInUseAuthorization() // 위치 사용 권한 요청
    self.locationManager.startUpdatingLocation() // 위치 업데이트 시작
  }
  
  // CLLocationManagerDelegate
  // 새로운 위치 데이터가 업데이트될 때 호출되는 델리게이트 메서드입니다.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // 1. locations 배열에서 가장 최근 위치 정보 가져오기
    guard let bestLocation = locations.last else { return }
    // 2. 현재 위치의 위도와 경도 추출
    let userLat = bestLocation.coordinate.latitude
    let userLng = bestLocation.coordinate.longitude
    
    print("1. 사용자의 위치 : (\(userLat), \(userLng))")
    
    // 3. 지도 뷰를 현재 위치로 이동시키는 메서드 호출
    self.cameraUpdate(lat: userLat, lng: userLng)
  }
  
  private func cameraUpdate(lat: Double, lng: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
    self.mapView.mapView.moveCamera(cameraUpdate)
  }
}
