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
    
    private let placeholderText = "상세 설명을 입력해주세요."
    private let firestore = Firestore.firestore() // Firestore 인스턴스 추가
    
    var selectedImage: UIImage? // 촬영한 사진 저장
    
    // 키보드의 높이
    private var keyboardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaverMapView()
        setupUI()
        setupKeyboardNotifications()  // 키보드 알림 설정
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

        // descriptionTextField의 플레이스홀더 설정
        descriptionTextField.placeholder = placeholderText
    }
    
    // MARK: - Keyboard Notifications
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = keyboardFrame.height
            // 키보드가 올라오면 화면을 위로 이동
            self.view.frame.origin.y = -keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // 키보드가 내려가면 화면을 원래 위치로 되돌린다
        self.view.frame.origin.y = 0
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmLocationTapped(_ sender: UIButton) {
        guard let smokingVC = storyboard?.instantiateViewController(withIdentifier: "AddSADataVC") as? AddSmokingAreaDataViewController else {
                print("SmokingArea 뷰컨 생성 실패")
                return
            }
            smokingVC.modalPresentationStyle = .fullScreen
            self.present(smokingVC, animated: true, completion: nil)
//        let currentCenter = naverMapView.mapView.cameraPosition.target
//
//        // 제목이 비어 있는지 확인
//        guard let title = titleTextField.text, !title.isEmpty else {
//            showAlert(message: "제목을 입력해주세요.") {
//                // 빈 제목 입력 시 추가 작업이 필요하면 여기 작성
//            }
//            return
//        }
//
//        // 상세 설명이 플레이스홀더와 같은지 확인하고 적절히 처리
//        let description = descriptionTextField.text == placeholderText ? "" : descriptionTextField.text
//
//        // Firestore에 데이터 추가
//        let smokingAreaData: [String: Any] = [
//            "name": title,
//            "latitude": currentCenter.lat,
//            "longitude": currentCenter.lng,
//            "description": description ?? "", // 설명이 nil일 경우 빈 문자열로 처리
//            "timestamp": Timestamp(date: Date()) // 데이터 추가 시간
//        ]
        
//        firestore.collection("smokingAreas").addDocument(data: smokingAreaData) { error in
//            if let error = error {
//                print("Firestore 저장 실패: \(error.localizedDescription)")
//                self.showAlert(message: "데이터 저장에 실패했습니다.") {}
//            } else {
//                print("Firestore 저장 성공")
//                self.showAlert(message: "새로운 흡연구역이 등록되었습니다!") {
//                    self.dismiss(animated: true, completion: nil)
//                }
//            }
//        }
        
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.sourceType = .camera
//        imagePickerController.delegate = self
//        present(imagePickerController, animated: true, completion: nil)
    }

    private func showAlert(message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completion()
        }))
        present(alert, animated: true, completion: nil)
    }
}
