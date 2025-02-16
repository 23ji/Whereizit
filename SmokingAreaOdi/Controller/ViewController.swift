// ViewController.swift

import UIKit
import NMapsMap
import FirebaseFirestore

class ViewController: UIViewController {
    // MARK: - Properties
    let locationManager = CLLocationManager()
    let markerManager = MarkerManager()
    
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var addMarkerButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
        
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaverMapView()
        setupView()
        
        // Firestore에서 데이터 가져오기
        fetchSmokingAreasFromFirestore()
        
        // NotificationCenter를 통해 마커 추가
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewSmokingArea(_:)), name: .newSmokingAreaAdded, object: nil)
    }
    
    // MARK: - Setup Methods
    private func setupNaverMapView() {
        let initialLocation = NMGLatLng(lat: 37.500920152198, lng: 127.03618231961)
        let cameraUpdate = NMFCameraUpdate(scrollTo: initialLocation)
        naverMapView.mapView.moveCamera(cameraUpdate)
        naverMapView.showLocationButton = true
    }
    
    private func setupView() {
        searchBar.searchTextField.borderStyle = .none
        searchBar.layer.cornerRadius = 15
        searchBar.clipsToBounds = true
    }
    
    // MARK: - Notification 처리 (마커 추가)
    @objc private func handleNewSmokingArea(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let newArea = userInfo["area"] as? SmokingArea else { return }
        
        markerManager.addMarker(for: newArea, to: naverMapView.mapView)
    }

    
    // MARK: - Actions
    @IBAction func addMarkerButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addVC = storyboard.instantiateViewController(withIdentifier: "AddSmokeAreaViewController") as? AddSmokeAreaViewController {
            addVC.modalPresentationStyle = .fullScreen
            present(addVC, animated: true, completion: nil)
        } else {
            print("AddSmokeAreaViewController를 찾을 수 없음")
        }
    }
    
    @IBAction func showListButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let listVC = storyboard.instantiateViewController(withIdentifier: "ListViewController") as? ListViewController {
            listVC.modalPresentationStyle = .fullScreen
            present(listVC, animated: true, completion: nil)
        } else {
            print("ListViewController를 찾을 수 없음")
        }
    }
}
