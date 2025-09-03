//
//  HomeViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/14/25.
//

import CoreLocation
import FirebaseCore
import FirebaseFirestore
import FloatingPanel
import NMapsMap
import PanModal
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
  
  
  // MARK: 바텀시트
  
  // TODO: 힌트 1
  // FloatingPanelController를 담을 변수를 선언해주세요.
  var floatingPanelController: FloatingPanelController?
  
  // TODO: 힌트 2
  // 바텀시트에 띄울 ViewController의 인스턴스를 생성해주세요.
  var smokingAreaBottomSheetVC = SmokingAreaBottomSheetViewController()
  
  // MARK: Rx
  
  private let markerTapped = PublishSubject<SmokingArea>()
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
    self.showBottomSheet()
    // TODO: 힌트 3
    // 마커가 탭 되었을 때의 동작을 처리하는 bind 함수를 호출해주세요.
    self.bind()
    
    // TODO: 힌트 4
    // 바텀시트를 설정하고 초기화하는 함수를 호출해주세요.
    
    self.mapView.mapView.touchDelegate = self
  }
  
  // MARK: Setup
  
  private func setup() { self.navigationItem.title = "Home" }
  
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
        
        guard let name = data["name"] as? String,
              let description = data["description"] as? String,
              let areaLat = data["areaLat"] as? Double,
              let areaLng = data["areaLng"] as? Double
        else { return }
        let selectedEnvironmentTags = (data["environmentTags"] as? [String]) ?? []
        let selectedTypeTags = (data["typeTags"] as? [String]) ?? []
        let selectedFacilityTags = (data["facilityTags"] as? [String]) ?? []
        
        
        let areaData = SmokingArea(
          name: name,
          description: description,
          areaLat: areaLat,
          areaLng: areaLng,
          selectedEnvironmentTags: selectedEnvironmentTags,
          selectedTypeTags: selectedTypeTags,
          selectedFacilityTags: selectedFacilityTags
        )
        
        let areaMarker = NMFMarker()
        areaMarker.iconImage = NMFOverlayImage(name: "marker_Pin")
        areaMarker.position = NMGLatLng(lat: areaLat, lng: areaLng)
        
        areaMarker.touchHandler = { (overlay: NMFOverlay) -> Bool in
          self.markerTapped.onNext(areaData)
          return true
        }
        areaMarker.mapView = self.mapView.mapView
      }
    }
  }
  
  // TODO: 힌트 5
  // markerTapped 이벤트를 구독(subscribe)하여 처리하는 bind() 함수를 만들어주세요.
  // 1. 마커에서 전달받은 SmokingArea 데이터로 바텀시트의 UI를 업데이트 해야합니다. (예: smokingAreaBottomSheetVC.configure(with:))
  // 2. 숨겨져 있는 바텀시트를 위로 올려서 보여줘야 합니다. (예: floatingPanel.move(to: .half, animated: true))
  private func bind() {
      // 1. markerTapped PublishSubject를 구독(subscribe)합니다.
      markerTapped
          .subscribe(onNext: { areaData in // 2. onNext 클로저에서 이벤트를 처리합니다. [weak self]로 순환 참조를 방지하세요.
              // 3. self가 해제되었을 경우를 대비해 guard let으로 안전하게 언래핑합니다.
              // 4. smokingAreaBottomSheetVC의 configure 메서드를 호출하여,
              //    마커에서 받아온 areaData를 전달하고 UI를 업데이트합니다.
              // self.smokingAreaBottomSheetVC.configure(with: areaData)

              // 5. 숨겨져 있는 floatingPanel(바텀시트)을 .half 상태로 올립니다.
              //    애니메이션과 함께 움직이도록 animated 파라미터를 true로 설정하세요.
            self.floatingPanelController?.move(to: .half, animated: true)
          })
          .disposed(by: disposeBag) // 6. 생성된 구독을 disposeBag에 추가하여 메모리 누수를 방지합니다.
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


// TODO: 힌트 6
// FloatingPanelControllerDelegate 프로토콜을 채택하고, 바텀시트를 설정하는 함수를 만들어주세요. (예: showBottomSheet)

extension HomeViewController: FloatingPanelControllerDelegate {
  func showBottomSheet() {
    // 1. FloatingPanelController 인스턴스 생성 및 delegate 설정
    floatingPanelController = FloatingPanelController()
    floatingPanelController?.delegate = self
    // 2. 바텀시트에 content로 들어갈 UIViewController 설정 (예: floatingPanel.set(contentViewController:))
    let smokingAreaBottomSheetVC = SmokingAreaBottomSheetViewController()
    floatingPanelController?.set(contentViewController: smokingAreaBottomSheetVC)
    // 3. 부모 뷰에 바텀시트 추가 (예: floatingPanel.addPanel(toParent:))
    floatingPanelController?.addPanel(toParent: self)
    // 4. 바텀시트의 초기 상태를 설정 (예: 숨김) (예: floatingPanel.move(to: .hidden, animated: false))
    floatingPanelController?.move(to: .hidden, animated: true)
    // + 추가: 바텀시트 외형 커스텀 (모서리 둥글게 등)
  }
}



extension HomeViewController: NMFMapViewTouchDelegate {
  func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
    // TODO: 힌트 7
    // 지도를 탭했을 때, 화면에 보이는 바텀시트를 다시 숨겨주세요.
  }
}
