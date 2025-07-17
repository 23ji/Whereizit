//
//  DetailView.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/17/25.
//
import NMapsMap
import UIKit

final class DetailView: UIView {
  
  // MARK: - properties
  
  
  private let mapView = NMFMapView()
  private let addButton = UIButton()
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  
  private let smokingAreaName = UILabel()
  
  
  // MARK: -
  
  
  // 초기화 메서드 (코드로 UI 작성 시 필수)
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()              // UI 구성 메서드 호출
    setMarker()
  }
  
  
  // storyboard 사용할 계획 없기 때문에 fatalError 처리
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - UI
  
  
  private func setupUI() {
    //지도
    self.addSubview(mapView)

    mapView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
      mapView.heightAnchor.constraint(equalToConstant: 200) // 원하는 높이 고정
    ])
    
    setupScroll()
    addContent()
  }
  
  // MARK: - Marker

  
  func setMarker() {
    let markerCoordinate = UIImageView(image: UIImage(named: "marker_Pin"))
    
    mapView.addSubview(markerCoordinate)
    
    markerCoordinate.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      markerCoordinate.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
      markerCoordinate.bottomAnchor.constraint(equalTo: self.mapView.centerYAnchor)
    ])
  }
  
  
  // MARK: - Scroll
  
  func setupScroll() {
    self.addSubview(scrollView)
    
    self.backgroundColor = .white
    
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
    ])
    
    scrollView.addSubview(contentView)
    
    contentView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.backgroundColor = .red
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
    ])
  }
  
  func addContent() {
    var lastView: UIView? = nil
      
    for i in 1...20 {
      let label = UILabel()
      label.text = "테스트 라벨 \(i)"
      label.font = .systemFont(ofSize: 16)
      label.translatesAutoresizingMaskIntoConstraints = false
      contentView.addSubview(label)
      
      NSLayoutConstraint.activate([
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        label.topAnchor.constraint(equalTo: lastView?.bottomAnchor ?? contentView.topAnchor, constant: 20)
      ])
      
      lastView = label
    }
      if let last = lastView {
        last.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
      }
    
  }
  
}
