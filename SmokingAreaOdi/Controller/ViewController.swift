import UIKit
import NMapsMap

class ViewController: UIViewController {
    // MARK: - Properties
    let markerManager = MarkerManager()
    var popUpVC: PopUpViewController?

    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var addMarkerButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var showListButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaverMapView()
        loadMarkers()
        popUpVC = PopUpViewController(parentView: self.view) // PopUpViewController 초기화
    }
    
    // MARK: - Setup Methods
    private func setupNaverMapView() {
        let initialLocation = NMGLatLng(lat: 37.500920152198, lng: 127.03618231961)
        let cameraUpdate = NMFCameraUpdate(scrollTo: initialLocation)
        naverMapView.mapView.moveCamera(cameraUpdate)
        naverMapView.showLocationButton = true
    }

    // MARK: - Firestore 데이터 불러와서 마커 추가
    private func loadMarkers() {
        FirestoreManager.shared.fetchSmokingAreas { [weak self] smokingAreas in
            guard let self = self else { return }
            
            self.markerManager.addMarkers(for: smokingAreas, to: self.naverMapView.mapView, viewController: self)
        }
    }

    // MARK: - 팝업 정보 표시
    func showPopUpInfo(for smokingArea: SmokingArea) {
        popUpVC?.showInfo(for: smokingArea) // PopUpViewController에서 정보 표시
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
