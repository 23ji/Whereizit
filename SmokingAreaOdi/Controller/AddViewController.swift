//
//  AddViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/16/25.
//
import NMapsMap

import UIKit


class AddViewController: UIViewController, NMFMapViewCameraDelegate {
  
  private let addView = AddView()
  let marker = NMFMarker()
  
  override func loadView() {
    view = addView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "흡연구역 추가"
    
    //카메라 델리게이트 등록해야함
    addView.mapView.addCameraDelegate(delegate: self)
  }
}
