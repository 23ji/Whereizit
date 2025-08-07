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
  var lat: Double?
  var lng: Double?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("내 마커 - 위도 : \(String(describing: lat)) 경도 : \(String(describing: lng))")
    self.setUI()
    self.defineFlexContainer()
  }
  
  private func setUI() {
    self.navigationItem.title = "흡연구역 등록"
  }
  
  private func addSubviews() {
    self.view.addSubview(self.mapView)
  }
  
  private func defineFlexContainer() {
    self.view.flex.addItem()
      .direction(.column)
      .alignItems(.stretch)
      .marginHorizontal(20)
      .define {
        $0.addItem(self.mapView).height(300)
      }
  }
  
  override func viewDidLayoutSubviews() { //?
    super.viewDidLayoutSubviews()
    self.view.flex.layout(mode: .fitContainer)
  }
}
