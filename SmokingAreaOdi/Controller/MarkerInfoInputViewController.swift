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
  
  
  // MARK: Properties
  
  var markerLat: Double?
  var markerLng: Double?
  
  private let db = Firestore.firestore()
  
  // ⭐️ 지도 초기 설정이 완료되었는지 확인하는 플래그
  private var isMapSetupCompleted = false
  
  
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
  
  private let environmentLabel = UILabel().then {
    $0.text = "환경"
    $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
  }
  
  private let environmentTags = UIButton().then {
    $0.setTitle("실내", for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 14)
    $0.backgroundColor = .systemGray6
    $0.setTitleColor(.label, for: .normal)
    $0.layer.cornerRadius = 15
    $0.layer.borderWidth = 0.7
    $0.layer.borderColor = UIColor.systemGray4.cgColor
  }
  
  private let saveButton = UIButton(type: .system).then {
    $0.setTitle("저장", for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.backgroundColor = .systemBlue
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 8
  }
  
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.setup()
    self.addSubView()
    
    self.defineFlexContainer()
    
    print("3. 전달받은 좌표 : \(self.markerLat), \(self.markerLng)")
    guard let lat = markerLat, let lng = markerLng else { return }
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
    self.mapView.moveCamera(cameraUpdate)
  }
  
  
  // MARK: setup
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.scrollView.pin.all(self.view.pin.safeArea)
    self.contentView.pin.top().horizontally()
    self.contentView.flex.layout(mode: .adjustHeight)
    self.scrollView.contentSize = self.contentView.frame.size
    
    // ⭐️ 마커 이미지 뷰를 mapView의 정중앙에 배치합니다.
    // x좌표는 mapView의 중앙, y좌표는 mapView의 중앙에서 이미지 높이의 절반만큼 위로 올립니다.
    // 이렇게 해야 이미지의 하단 중앙(꼭짓점)이 mapView의 정중앙에 위치하게 됩니다.
    let mapCenter = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.midY)
    markerCoordinateImageView.center = CGPoint(x: mapCenter.x, y: mapCenter.y - (markerCoordinateImageView.bounds.height / 2))
  }
  
  private func setup() {
    self.navigationItem.title = "흡연구역 등록"
    self.descriptionTextView.delegate = self
    self.mapView.allowsScrolling = false
  }
  
  private func addSubView() {
    self.view.addSubview(self.scrollView)
    self.scrollView.addSubview(self.contentView)
    self.mapView.addSubview(markerCoordinateImageView)
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
            $0.addItem(self.environmentLabel).height(Metric.labelHeight)
          }
        
        // 저장 버튼
        $0.addItem(saveButton).height(Metric.saveButtonHeight).marginTop(20).marginBottom(40)
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
