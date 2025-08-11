//
//  HomeViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/14/25.
//
import CoreLocation
import NMapsMap
import SnapKit
import Then

import UIKit


final class HomeViewController: UIViewController, CLLocationManagerDelegate, NMFMapViewCameraDelegate {
  
  // MARK: Constant
  
  private enum Metric {
    static let addButtonSize: CGFloat = 56
    static let addButtonTrailing: CGFloat = 24
    static let addButtonBottom: CGFloat = 40
  }
  
  
  // MARK: UI
  
  private let mapView = NMFNaverMapView()
  private let addButton = UIImageView(image: UIImage(named: "plusButton")).then {
    $0.isUserInteractionEnabled = true // 터치 가능하게 꼭 켜야함
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Home"

    self.addSubviews()
    self.setLocationManager()
    
    self.makeConstraints()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAddButton))
    addButton.addGestureRecognizer(tapGesture)
  }
  
  
  private func addSubviews() {
    self.view.addSubview(self.mapView)
    self.view.addSubview(self.addButton)
  }
  
  private func setLocationManager() {
    self.mapView.showLocationButton = true
  }
  
  
  private func makeConstraints() {
    self.mapView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    self.addButton.snp.makeConstraints{
      $0.size.equalTo(Metric.addButtonSize)
      $0.trailing.equalToSuperview().inset(Metric.addButtonTrailing)
      $0.bottom.equalToSuperview().inset(Metric.addButtonBottom)
    }
  }
  
  
  // MARK: Configure
  
  @objc private func didTapAddButton() {
    let makerPositionSeletorVC = MarkerPositionSelectorViewController()
    self.navigationController?.pushViewController(makerPositionSeletorVC, animated: true)
  }
}
