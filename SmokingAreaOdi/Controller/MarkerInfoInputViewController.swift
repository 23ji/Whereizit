//
//  MarkerInfoInputViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/17/25.
//
import FirebaseCore
import FirebaseFirestore
import FlexLayout
import IQKeyboardManagerSwift
import NMapsMap
import Then

import UIKit

final class MarkerInfoInputViewController: UIViewController, CLLocationManagerDelegate, NMFMapViewCameraDelegate {
  
  // MARK: Constant
  
  private enum Metric {
    static let mapHeight: CGFloat = 200
    static let labelFontSize: CGFloat = 16
    static let labelHeight: CGFloat = 50
    static let textfontSize: CGFloat = 16
    static let textFieldHeight: CGFloat = 40
    static let textViewHeight: CGFloat = 80
    static let horizontalMargin: CGFloat = 20
    static let inPutsMargin: CGFloat = 10
    static let saveButtonHeight: CGFloat = 50
  }
  
  
  // MARK: UI
  
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let mapView = NMFMapView()
  private let markerCoordinateImageView = UIImageView(image: UIImage(named: "marker_Pin"))
  private let locationManager = CLLocationManager()

  private let nameLabel = UILabel().then {
    $0.text = "흡연구역 이름"
    $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
  }
  private let nameTextField = UITextField().then {
    $0.placeholder = "강남역 11번 출구"
    $0.borderStyle = .roundedRect
    $0.font = UIFont.systemFont(ofSize: Metric.textfontSize)
  }
  
  private let descriptionLabel = UILabel().then {
    $0.text = "흡연구역 설명"
    $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
  }
  private let descriptionTextView = UITextView().then {
    $0.text = "우측으로 5m"
    $0.textColor = .systemGray3
    $0.layer.borderWidth = 0.5
    $0.layer.borderColor = UIColor.systemGray4.cgColor
    $0.layer.cornerRadius = 5
    $0.textContainerInset = UIEdgeInsets(top: 10, left: 3, bottom: 10, right: 3)
    $0.font = UIFont.systemFont(ofSize: Metric.textfontSize)
  }
  
  
  private let saveButton = UIButton(type: .system).then {
    $0.setTitle("저장", for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.backgroundColor = .systemBlue
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 8
    $0.addTarget(MarkerInfoInputViewController.self, action: #selector(saveData), for: .touchUpInside)
  }
  
  
  // MARK: Properties
  
  var markerLat: Double?
  var markerLng: Double?
  private let db = Firestore.firestore()
  enum tagType: String {
    case 환경
    case 유형
    case 시설
  }
  //개선하기
  private let tagData: [tagType: [String]] = [
    .환경: ["실내", "실외", "밀폐형", "개방형"],
    .유형: ["카페", "술집", "피시방", "식당"],
    .시설: ["재떨이", "의자", "별도 전자담배 구역"]
  ]
  //Set 사용 지양하기
  private var selectedTags: Set<String> = []
  
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.addSubView()
    self.setup()
    //self.cameraUpdate(lat: Double(areaLat!), lng: Double(areaLng!))
    self.defineFlexContainer()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.scrollView.pin.all(self.view.pin.safeArea)
    self.contentView.pin.top().horizontally()
    self.contentView.flex.layout(mode: .adjustHeight)
    self.scrollView.contentSize = contentView.frame.size
  }
  
  
  // MARK: addSubView
  
  private func addSubView() {
    self.view.addSubview(self.scrollView)
    self.scrollView.addSubview(self.contentView)
    self.mapView.addSubview(markerCoordinateImageView)
  }
  
  
  // MARK: Setup
  
  private func setup() {
    self.navigationItem.title = "흡연구역 등록"
    self.descriptionTextView.delegate = self
    self.mapView.isExclusiveTouch = false
  }
  
  private var marker = NMFMarker()

  private func setLocationManager() {
      // 델리게이트를 self로 설정합니다.
      self.locationManager.delegate = self
      
      // 위치 정확도를 '내비게이션에 최적인 정확도'로 설정합니다.
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
      
      // 위치 업데이트를 받기 위해 필요한 최소 거리를 0으로 설정합니다.
      self.locationManager.distanceFilter = kCLDistanceFilterNone
      
      // '앱 사용 중' 위치 권한을 요청합니다.
      self.locationManager.requestWhenInUseAuthorization()
      
      // 위치 업데이트를 시작합니다.
      self.locationManager.startUpdatingLocation()
  }

  // CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      // 가장 최근의 위치 정보를 가져옵니다.
      guard let location = locations.last else { return }
      
      let lat = location.coordinate.latitude
      let lng = location.coordinate.longitude
      print("정확도: \(location.horizontalAccuracy)m")
      
      // 수평 정확도가 10m보다 작을 때(즉, 더 정확할 때)만 로직을 실행합니다.
      if location.horizontalAccuracy > 0 && location.horizontalAccuracy <= 10 {
          // 카메라를 현재 위치로 이동시킵니다.
          cameraUpdate(lat: lat, lng: lng)
          
          // 기존 마커가 있다면 위치만 업데이트하고, 없다면 새로 생성하여 지도에 표시합니다.
          // 마커의 위치를 업데이트합니다.
          marker.position = NMGLatLng(lat: lat, lng: lng)
          
          // 마커가 지도에 표시되어 있지 않다면, 지도에 추가합니다.
          if marker.mapView == nil {
              marker.mapView = self.mapView
          }
          
          // 원하는 정확도에 도달하면 더 이상 위치 업데이트를 중지합니다.
          locationManager.stopUpdatingLocation()
      }
  }

  private func cameraUpdate(lat: Double, lng: Double) {
      let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
      self.mapView.moveCamera(cameraUpdate)
  }
  
  
  // MARK: Layout
  
  //개선하기 / 분리하기
  private func defineFlexContainer() {
    self.contentView.flex
      .direction(.column)
      .define {
        $0.addItem(self.mapView).height(Metric.mapHeight)
        
        
        $0.addItem()
          .direction(.column)
          .paddingHorizontal(Metric.horizontalMargin)
          .define {
            $0.addItem(self.nameLabel).height(Metric.labelHeight)
            $0.addItem(self.nameTextField).height(Metric.textFieldHeight).marginBottom(10)
            $0.addItem(self.descriptionLabel).height(Metric.labelHeight)
            $0.addItem(self.descriptionTextView).height(Metric.textViewHeight).marginBottom(10)
            
            for (category, tags) in tagData {
              let label = UILabel()
              label.text = category.rawValue
              label.font = .boldSystemFont(ofSize: Metric.labelFontSize)
              $0.addItem(label).marginTop(Metric.inPutsMargin).marginBottom(Metric.inPutsMargin)
              $0.addItem().direction(.row).wrap(.wrap).define { tagFlex in
                for tag in tags {
                  let button = tagButton(title: tag)
                  tagFlex.addItem(button).marginRight(Metric.inPutsMargin).marginBottom(Metric.inPutsMargin)
                }
              }
            }
            
            // 저장 버튼
            $0.addItem(saveButton).height(Metric.saveButtonHeight).marginTop(20).marginBottom(40)
          }
      }
  }
  
  
  private func tagButton(title: String) -> UIButton {
    let button = UIButton(type: .system).then {
      $0.setTitle(title, for: .normal)
      $0.titleLabel?.font = .systemFont(ofSize: 14)
      $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
      $0.layer.cornerRadius = 16
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.systemGray4.cgColor
      $0.backgroundColor = .systemGray6
      $0.setTitleColor(.label, for: .normal)
    }
    button.addAction(UIAction { [weak self] _ in
      self?.toggleTagSelection(tag: title, button: button)
    }, for: .touchUpInside)
    return button
  }
  
  private func toggleTagSelection(tag: String, button: UIButton) {
    
    // 모두 삼항연산자 처리할 방법 찾아보기,,
    let isSelected = selectedTags.contains(tag)
    if isSelected {
      selectedTags.remove(tag)
    } else {
      selectedTags.insert(tag)
    }
    button.backgroundColor = isSelected ? .systemGray6 : .systemBlue
    button.setTitleColor(isSelected ? .label : .white, for: .normal)
    print("선택된 태그: \(selectedTags)")
  }
  
  
  // MARK: Firebase 저장
  
  @objc private func saveData() {
    guard let markerLat = self.markerLat else { return }
    
    guard let manerLng = markerLng,
          let areaName = self.nameTextField.text, !areaName.isEmpty,
          let areaDescription = self.descriptionTextView.text, !description.isEmpty else {
      print("필수값 누락")
      return
    }
    
    let data: [String: Any] = [
      "markerLat": markerLat,
      "markerLng": markerLng,
      "areaName": areaName,
      "areaDescription": areaDescription,
      "tags": Array(selectedTags),
      "createdAt": Timestamp(date: Date())
    ]
    
    db.collection("smokingAreas").addDocument(data: data) { error in
      if let error = error {
        print("저장 실패: \(error.localizedDescription)")
      } else {
        print("저장 성공")
        self.navigationController?.popToRootViewController(animated: true)
      }
    }
  }
}


// MARK:  UITextViewDelegate

extension MarkerInfoInputViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    self.descriptionTextView.text = nil
    self.descriptionTextView.textColor = .label
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      self.descriptionTextView.text = "우측으로 5m"
      self.descriptionTextView.textColor = .systemGray3
    }
  }
}
