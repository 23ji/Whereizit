import UIKit
import NMapsMap
import FirebaseFirestore

extension Notification.Name {
  static let smokingAreaAdded = Notification.Name("smokingAreaAdded")
}


class AddSmokeAreaViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var naverMapView: NMFNaverMapView!
  @IBOutlet weak var titleTextField: UITextField!   // 제목 텍스트 필드
  @IBOutlet weak var descriptionTextField: UITextField!   // 상세 설명을 위한 텍스트 필드
  
  private let firestore = Firestore.firestore() // Firestore 인스턴스 추가
  
  var selectedImage: UIImage? // 촬영한 사진 저장
  var marker: NMFMarker?
  

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNaverMapView()
    setupUI()
    
    
  }
  
  deinit {
    // 메모리 해제를 위해 알림 등록 해제
    NotificationCenter.default.removeObserver(self)
  }
  
  private func setupNaverMapView() {
    let initialLocation = NMGLatLng(lat: 37.500920152198, lng: 127.03618231961)
    let cameraUpdate = NMFCameraUpdate(scrollTo: initialLocation)
    naverMapView.mapView.moveCamera(cameraUpdate)
    naverMapView.showLocationButton = true
  }
  
  private func setupUI() {
    searchBar.searchTextField.borderStyle = .none
    searchBar.layer.cornerRadius = 15
    searchBar.clipsToBounds = true
    
    self.tabBarController?.tabBar.isHidden = true
  }
  
  @IBAction func backButtonTapped(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func confirmLocationTapped(_ sender: UIButton) {
    guard let smokingVC = storyboard?.instantiateViewController(withIdentifier: "AddSADataVC") as? AddSmokingAreaDataViewController else {
      print("SmokingArea 뷰컨 생성 실패")
      return
    }
    
    let currentCenter = naverMapView.mapView.cameraPosition.target
    smokingVC.latitude = currentCenter.lat
    smokingVC.longitude = currentCenter.lng
    
    smokingVC.modalPresentationStyle = .fullScreen
    self.present(smokingVC, animated: true, completion: nil)
  }
}
