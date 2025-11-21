//
//  HomeViewController.swift
//  Whereizit
//
//  Created by 이상지 on 7/14/25.
//

import SnapKit
import Then

import RxSwift
import RxCocoa

import CoreLocation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

import FloatingPanel

import NMapsMap

import UIKit

import ReactorKit


final class HomeViewController: UIViewController {
  
  // MARK: Constant
  
  private enum Metric {
    static let addButtonTrailing: CGFloat = 24
    static let addButtonBottom: CGFloat = 180
  }
  
  
  // MARK: UI
  
  private let mapView = NMFNaverMapView()
  private let addButton = UIButton().then {
    $0.setImage(UIImage(named: "plusButton"), for: .normal)
    $0.layer.shadowOpacity = 0.1
  }
  
  
  // MARK: Property
  
  private let db = Firestore.firestore()
  private let locationManager = CLLocationManager()
  
  // MARK: [FIX] 현재 지도에 표시된 마커를 Document ID를 키로 하는 딕셔너리로 변경 (효율적인 관리)
  private var areaMarkers: [String: NMFMarker] = [:]
  
  
  // MARK: 바텀시트
  
  var nearbyPanel: FloatingPanelController!
  var tappedPanel: FloatingPanelController!
  
  var nearByAreasBottomSheetVC = NearbyAreasBottomSheetViewController()
  var areaBottomSheetVC = areaBottomSheetViewController()

  
  // MARK: Rx
  
  private let markerTapped = PublishSubject<Area>()
  private let disposeBag = DisposeBag()
  
  
  // MARK: LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureMapView()
    self.addSubviews()
    self.makeConstraints()
    self.setLocationManager()
    self.observeAreas()
    self.setupPanels()
    self.bind()
    
    self.mapView.mapView.touchDelegate = self
  }
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
      self.mapView.mapView.contentInset = UIEdgeInsets(
        top: 0,
        left: 0,
        bottom: tabBarHeight - 10, // TODO: Metric
        right: 0
      )
    }
  }
  
  
  // MARK: Setup
  
  private func configureMapView() {
    self.mapView.mapView.zoomLevel = 16.0
    self.mapView.showLocationButton = true
  }
  
  private func addSubviews() {
    self.view.addSubview(self.mapView)
    self.view.addSubview(self.addButton)
  }
  
  private func makeConstraints() {
    self.mapView.snp.makeConstraints { $0.edges.equalToSuperview() }
    
    self.addButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(Metric.addButtonTrailing)
      $0.bottom.equalToSuperview().inset(Metric.addButtonBottom)
    }
  }
  
  // MARK: Area Marker
  
  // 기존 마커 전체를 제거하는 함수 (선택적으로 사용)
  private func clearMarkers() {
    self.areaMarkers.values.forEach { $0.mapView = nil }
    self.areaMarkers.removeAll()
  }
  
  private func observeAreas() {
    // [FIX] snapshot.documentChanges를 사용하여 효율적으로 마커를 관리합니다.
    db.collection("smokingAreas").addSnapshotListener { [weak self] snapshot, error in
      guard let self = self, let snapshot = snapshot else { return }
      
      for change in snapshot.documentChanges {
        let doc = change.document
        let data = doc.data()
        let documentID = doc.documentID
        
        // Document Data 파싱
        guard let name = data["name"] as? String,
              let description = data["description"] as? String,
              let areaLat = data["areaLat"] as? Double,
              let areaLng = data["areaLng"] as? Double
        else { continue } // 데이터 파싱 실패 시 건너뜀
        
        let imageURL = data["imageURL"] as? String ?? ""
        let category = data["category"] as? String ?? ""
        let selectedEnvironmentTags = (data["environmentTags"] as? [String]) ?? []
        let selectedTypeTags = (data["typeTags"] as? [String]) ?? []
        let selectedFacilityTags = (data["facilityTags"] as? [String]) ?? []
        let uploadTimestamp = data["uploadDate"] as? Timestamp ?? Timestamp(date: Date())
        let uploadUser = data["uploadUser"] as? String ?? ""
        
        let areaData = Area(
          documentID: documentID,
          imageURL: imageURL,
          name: name,
          description: description,
          areaLat: areaLat,
          areaLng: areaLng,
          category: category,
          selectedEnvironmentTags: selectedEnvironmentTags,
          selectedTypeTags: selectedTypeTags,
          selectedFacilityTags: selectedFacilityTags,
          uploadUser: uploadUser,
          uploadDate: uploadTimestamp
        )
        
        switch change.type {
        case .added:
          let areaMarker = NMFMarker()
          areaMarker.iconImage = switch areaData.category {
          case "흡연구역": NMFOverlayImage(name: "smokingMarker")
          case "화장실": NMFOverlayImage(name: "toiletMarker")
          case "쓰레기통": NMFOverlayImage(name: "trashMarker")
          case "물": NMFOverlayImage(name: "waterMarker")
          default: NMFOverlayImage(name: "marker_Pin_Wind")
          }
          areaMarker.position = NMGLatLng(lat: areaData.areaLat, lng: areaData.areaLng)
          
          areaMarker.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
            self?.markerTapped.onNext(areaData)
            return true
          }
          
          areaMarker.mapView = self.mapView.mapView
          self.areaMarkers[documentID] = areaMarker
          
        case .modified:
          if let existingMarker = self.areaMarkers[documentID] {
            existingMarker.mapView = nil // 지도에서 제거
            self.areaMarkers.removeValue(forKey: documentID) // 딕셔너리에서 제거
            
            let areaMarker = NMFMarker()
            areaMarker.iconImage = switch areaData.category {
            case "흡연구역": NMFOverlayImage(name: "smokingMarker")
            case "화장실": NMFOverlayImage(name: "toiletMarker")
            case "쓰레기통": NMFOverlayImage(name: "trashMarker")
            case "물": NMFOverlayImage(name: "waterMarker")
            default: NMFOverlayImage(name: "marker_Pin_Wind")
            }
            areaMarker.position = NMGLatLng(lat: areaData.areaLat, lng: areaData.areaLng)
            
            areaMarker.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
              self?.markerTapped.onNext(areaData)
              return true
            }
            
            areaMarker.mapView = self.mapView.mapView
            self.areaMarkers[documentID] = areaMarker
            
            self.tappedPanel.move(to: .hidden, animated: true)
            self.nearbyPanel.move(to: .tip, animated: true)
          }
          
        case .removed:
          if let existingMarker = self.areaMarkers[documentID] {
            existingMarker.mapView = nil // 지도에서 제거
            self.areaMarkers.removeValue(forKey: documentID) // 딕셔너리에서 제거
            
            self.tappedPanel.move(to: .hidden, animated: true)
            self.nearbyPanel.move(to: .tip, animated: true)
          }
        }
      }
    }
  }
  
  
  private func bind() {
    self.markerTapped
      .subscribe(onNext: { [weak self] areaData in
        guard let self = self else { return }
        self.areaBottomSheetVC.configure(with: areaData)
        self.tappedPanel.move(to: .half, animated: true)
        self.nearbyPanel.move(to: .hidden, animated: true)
        self.moveCameraToArea(lat: areaData.areaLat, lng: areaData.areaLng)
      })
      .disposed(by: disposeBag)
    
    self.addButton.rx.tap
      .asDriver()
      .drive(onNext : { [weak self] in
        let markerPositionSeletorVC = MarkerPositionSelectorViewController()
        markerPositionSeletorVC.modalPresentationStyle = .fullScreen
        self?.present(markerPositionSeletorVC, animated: true)
      })
      .disposed(by: self.disposeBag)
  }
}


// MARK: Location / Camera

extension HomeViewController: CLLocationManagerDelegate {
  
  private func setLocationManager() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    self.locationManager.distanceFilter = kCLDistanceFilterNone
    self.locationManager.activityType = .otherNavigation
    self.locationManager.pausesLocationUpdatesAutomatically = false
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    guard let bestLocation = locations.last else { return }
    
    let userLat = bestLocation.coordinate.latitude
    let userLng = bestLocation.coordinate.longitude
    
    print("1. 사용자의 위치 : (\(userLat), \(userLng))")
    
    self.cameraUpdate(lat: userLat, lng: userLng)
    manager.stopUpdatingLocation()
  }
  
  private func cameraUpdate(lat: Double, lng: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
    self.mapView.mapView.moveCamera(cameraUpdate)
  }
}


// MARK: FloatingPanel

extension HomeViewController: FloatingPanelControllerDelegate {
  
  func setupPanels() {
    // Nearby 패널
    self.nearbyPanel = FloatingPanelController()
    self.nearbyPanel.surfaceView.layer.cornerRadius = 15
    self.nearbyPanel.surfaceView.layer.masksToBounds = true
    self.nearbyPanel.set(contentViewController: nearByAreasBottomSheetVC)
    self.nearbyPanel.addPanel(toParent: self)
    self.nearbyPanel.move(to: .tip, animated: false)
    
    self.nearByAreasBottomSheetVC.delegate = self
    
    // Tapped 패널
    self.tappedPanel = FloatingPanelController()
    self.tappedPanel.delegate = self
    self.tappedPanel.surfaceView.layer.cornerRadius = 15
    self.tappedPanel.surfaceView.layer.masksToBounds = true
    self.tappedPanel.set(contentViewController: areaBottomSheetVC)
    self.tappedPanel.addPanel(toParent: self)
    self.tappedPanel.move(to: .hidden, animated: false)
  }
  
  func floatingPanelWillEndDragging(_ fpc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {
    if fpc == self.tappedPanel && fpc.state == .half && velocity.y > 0 {
      self.nearbyPanel.move(to: .tip, animated: false)
      print("작동")
    }
  }
  
  func floatingPanelDidMove(_ fpc: FloatingPanelController) {
    if fpc == self.tappedPanel && fpc.state == .tip {
      self.tappedPanel.move(to: .hidden, animated: false)
    }
  }
}



extension HomeViewController: NMFMapViewTouchDelegate {
  func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
    self.nearbyPanel.move(to: .tip, animated: true)
    self.tappedPanel.move(to: .hidden, animated: true)
  }
}


extension HomeViewController: NearbyAreasDelegate {
  func moveCameraToArea(lat: Double, lng: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
    cameraUpdate.animation = .easeIn
    self.mapView.mapView.moveCamera(cameraUpdate)
  }
  
  
  func showAreaBottomSheet(areaData: Area) {
    self.areaBottomSheetVC.configure(with: areaData)
    self.tappedPanel.move(to: .half, animated: true)
    self.nearbyPanel.move(to: .hidden, animated: true)
    print("showAreaBottomSheet 동작")
  }
}
