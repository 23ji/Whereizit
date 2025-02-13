//
//  AddSmokingAreaDataViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 1/31/25.
//

import UIKit
import NMapsMap
import FirebaseFirestore


class AddSmokingAreaDataViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var titleTextField: UITextField!   // 제목 텍스트 필드
    @IBOutlet weak var descriptionTextField: UITextField!   // 상세 설명을 위한 텍스트 필드

    private let firestore = Firestore.firestore() // Firestore 인스턴스 추가
    private let placeholderText = "상세 설명을 입력해주세요."
    private var marker: NMFMarker!

    
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNaverMapView()
    }
    
    private func setupUI() {

        // descriptionTextField의 플레이스홀더 설정
        descriptionTextField.placeholder = placeholderText
    }
    
    private func setupNaverMapView() {
        // 전달받은 좌표로 지도 이동 & 마커 표시
        if let lat = latitude, let lng = longitude {
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
            naverMapView.mapView.moveCamera(cameraUpdate)
            
            // 마커 생성 및 사용자 이미지 설정
            marker = NMFMarker()
            marker.position = NMGLatLng(lat: lat, lng: lng)
            marker.iconImage = NMFOverlayImage(name: "marker_Pin")
            marker.mapView = naverMapView.mapView
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmLocationTapped(_ sender: UIButton) {
        let currentCenter = naverMapView.mapView.cameraPosition.target
        
        // 제목이 비어 있는지 확인
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "제목을 입력해주세요.") {
                // 빈 제목 입력 시 추가 작업이 필요하면 여기 작성
            }
            return
        }
        
        // 상세 설명이 플레이스홀더와 같은지 확인하고 적절히 처리
        let description = descriptionTextField.text == placeholderText ? "" : descriptionTextField.text
        
        // Firestore에 데이터 추가
        let smokingAreaData: [String: Any] = [
            "name": title,
            "latitude": currentCenter.lat,
            "longitude": currentCenter.lng,
            "description": description ?? "", // 설명이 nil일 경우 빈 문자열로 처리
            "timestamp": Timestamp(date: Date()) // 데이터 추가 시간
        ]
        
        firestore.collection("smokingAreas").addDocument(data: smokingAreaData) { error in
            if let error = error {
                print("Firestore 저장 실패: \(error.localizedDescription)")
                self.showAlert(message: "데이터 저장에 실패했습니다.") {}
            } else {
                print("Firestore 저장 성공")
                self.showAlert(message: "새로운 흡연구역이 등록되었습니다!") {
                    if let navigationController = self.navigationController {
                        // 네비게이션 컨트롤러가 있으면 첫 번째 화면으로 돌아감
                        navigationController.popToRootViewController(animated: true)
                    } else {
                        print("Firestore 저장 성공")
                        self.showAlert(message: "새로운 흡연구역이 등록되었습니다!") {
                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VC") as? ViewController
                        }
                    }
                }
            }
        }
        //카메라 실행
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


