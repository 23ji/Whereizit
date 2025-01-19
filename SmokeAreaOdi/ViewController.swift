import UIKit
import NMapsMap

class ViewController: UIViewController {
    // MARK: - Properties
    let locationManager = CLLocationManager()
    var markerManager: MarkerManager?  // 마커 매니저
    
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var addMarkerButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var isChecked = false  // 버튼 상태
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNaverMapView()
        addSmokingAreaMarkers()
        setupView()
        
        // 마커 매니저 초기화
        markerManager = MarkerManager(mapView: naverMapView.mapView)
        
        // NotificationCenter에서 흡연구역 추가 알림을 받음
        NotificationCenter.default.addObserver(self, selector: #selector(smokingAreaAdded(_:)), name: .smokingAreaAdded, object: nil)
    }
    
    // MARK: - Setup Methods
    private func setupNaverMapView() {
        let initialLocation = NMGLatLng(lat: 37.500920152198, lng: 127.03618231961)
        let cameraUpdate = NMFCameraUpdate(scrollTo: initialLocation)
        naverMapView.mapView.moveCamera(cameraUpdate)
        naverMapView.showLocationButton = true
    }
    
    private func addSmokingAreaMarkers() {
        // UserDefaults에서 저장된 데이터 가져오기
        let areas = smokingAreas
        
        for area in areas {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: area.latitude, lng: area.longitude)
            marker.captionText = area.name
            marker.mapView = naverMapView.mapView
        }
    }
    
    private func setupView(){
        // 흰색 테두리 없애기
        searchBar.searchTextField.borderStyle = .none
        searchBar.layer.cornerRadius = 15
        searchBar.clipsToBounds = true
    }
    
    // MARK: - NotificationCenter Method
    @objc private func smokingAreaAdded(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let newArea = userInfo["area"] as? SmokingArea else { return }
        
        // 새로운 마커 추가
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: newArea.latitude, lng: newArea.longitude)
        marker.captionText = newArea.name
        marker.mapView = naverMapView.mapView
    }
    
    @IBAction func addMarkerButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addVC = storyboard.instantiateViewController(withIdentifier: "AddSmokeAreaViewController") as? AddSmokeAreaViewController {
            addVC.modalPresentationStyle = .fullScreen // 화면 전체로 표시 (선택 사항)
            present(addVC, animated: true, completion: nil)
        } else {
            print("AddSmokeAreaViewController를 찾을 수 없음")
        }
    }
    
    @IBAction func showListButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let listVC = storyboard.instantiateViewController(withIdentifier: "ListViewController") as? ListViewController {
            listVC.modalPresentationStyle = .fullScreen  // 화면 전체로 표시
            present(listVC, animated: true, completion: nil)
        }
    }


}
