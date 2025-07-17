//
//  DetailViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/17/25.
//

import UIKit

class DetailViewController: UIViewController {
  
  let detailView = DetailView()
  
  var lat: Double?
  var lng: Double?
  
  
  override func loadView() {
    view = detailView
    print("내 마커 - 위도 : \(String(describing: lat)) 경도 : \(String(describing: lng))")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "흡연구역 등록"
    //view.backgroundColor = .white
  }
}
