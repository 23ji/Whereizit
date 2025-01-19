import UIKit
import NMapsMap

extension Notification.Name {
    static let smokingAreaAdded = Notification.Name("smokingAreaAdded")
}

class AddSmokeAreaViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var titleTextField: UITextField!   // 제목 텍스트 필드
    @IBOutlet weak var descriptionTextField: UITextField!   // 상세 설명을 위한 텍스트 필드
    
    private let placeholderText = "상세 설명을 입력해주세요."

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaverMapView()
        setupUI()
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

        // descriptionTextField의 플레이스홀더 설정
        descriptionTextField.placeholder = placeholderText
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmLocationTapped(_ sender: UIButton) {
        let currentCenter = naverMapView.mapView.cameraPosition.target

        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "제목을 입력해주세요.") {
                // 빈 제목 입력 시 처리
            }
            return
        }

        // 플레이스홀더와 실제 텍스트 구분
        let description = descriptionTextField.text == placeholderText ? "" : descriptionTextField.text

        // 새로운 흡연구역 데이터 생성
        let newSmokingArea = SmokingArea(name: title, latitude: currentCenter.lat, longitude: currentCenter.lng, description: description ?? "")

        // 새로운 흡연구역을 SmokingAreaData에 추가
        var updatedSmokingAreas = smokingAreas
        updatedSmokingAreas.append(newSmokingArea)
        smokingAreas = updatedSmokingAreas

        // NotificationCenter로 데이터 전달
        NotificationCenter.default.post(name: .smokingAreaAdded, object: nil, userInfo: ["area": newSmokingArea])

        showAlert(message: "새로운 흡연구역이 등록되었습니다!") {
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func showAlert(message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completion()
        }))
        present(alert, animated: true, completion: nil)
    }
}
