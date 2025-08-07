//
//  MarkerInfoInputViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/17/25.
//
import FlexLayout
import NMapsMap

import UIKit


class MarkerInfoInputViewController: UIViewController {
  
  private let mapView = NMFMapView()
  private let nameLabel = UILabel()
  private let nameTextField = UITextField()
  private let descriptionLabel = UILabel()
  private let descriptionTextField = UITextField()
  var lat: Double?
  var lng: Double?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("내 마커 - 위도 : \(String(describing: lat)) 경도 : \(String(describing: lng))")
    self.setUI()
    self.defineFlexContainer()
    self.setupInputs()
  }
  
  
  private func setUI() {
    self.navigationItem.title = "흡연구역 등록"
    self.view.backgroundColor = .white
  }
  
  
  private func setupInputs() {
    self.nameLabel.text = "흡연구역 이름"
    self.nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
    
    self.nameTextField.placeholder = "강남역 11번 출구"
    self.nameTextField.borderStyle = .roundedRect
    
    self.descriptionLabel.text = "흡연구역 설명"
    self.descriptionLabel.font = .systemFont(ofSize: 16, weight: .bold)
  
    self.descriptionTextField.placeholder = "우측으로 5m"
    self.descriptionTextField.borderStyle = .roundedRect
  }
  
  
  private func defineFlexContainer() {
    self.view.flex.addItem()
      .direction(.column)
      .alignItems(.stretch)
      .define {
        $0.addItem(self.mapView).height(300)
      }
    
    self.view.flex.addItem()
      .direction(.column)
      .alignItems(.stretch)
      .marginHorizontal(20)
      .define {
        $0.addItem(self.nameLabel).height(50)
        $0.addItem(self.nameTextField).height(40)
        $0.addItem(self.descriptionLabel).height(50)
        $0.addItem(self.descriptionTextField).height(40)
      }
  }
  
  
  override func viewDidLayoutSubviews() { //?
    super.viewDidLayoutSubviews()
    self.view.flex.layout(mode: .fitContainer)
  }
}
