//
//  ViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/14/25.
//
import NMapsMap
import UIKit

final class ViewController: UIViewController {

// MARK: - Properties

@IBOutlet weak var addMarkerButton: UIButton!
@IBOutlet weak var searchBar: UISearchBar!
@IBOutlet weak var showListButton: UIButton!
@IBOutlet weak var topStackView: UIStackView!


// MARK: - Lifecycle

override func viewDidLoad() {
super.viewDidLoad()
let mapView = NMFMapView(frame: view.frame)
view.addSubview(mapView)
//self.setupNaverMapView() //코드 리뷰에 용이하도록 self 사용
//self.setUp()
}


// MARK: - Setup Methods

private func setupNaverMapView() {
//    let initialLocation = NMGLatLng(lat: 37.500920152198, lng: 127.03618231961)
//    let cameraUpdate = NMFCameraUpdate(scrollTo: initialLocation)
//    naverMapView.mapView.moveCamera(cameraUpdate)
//    naverMapView.showLocationButton = true
}

private func setUp() {
//topStackView.layer.cornerRadius = 10
//topStackView.clipsToBounds = true

}
}


