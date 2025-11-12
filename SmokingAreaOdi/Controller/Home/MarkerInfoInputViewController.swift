//
//  MarkerInfoInputViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/17/25.
//

import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore

import FlexLayout
import Then

import IQKeyboardManagerSwift

import NMapsMap

import RxSwift
import RxCocoa

import UIKit

final class MarkerInfoInputViewController: UIViewController {
  
  // MARK: Constant
  
  private enum Metric {
    static let imageMargin: CGFloat = 20
    static let imageSize: CGFloat = 70
    static let labelFontSize: CGFloat = 16
    static let labelHeight: CGFloat = 50
    static let textfontSize: CGFloat = 16
    static let textFieldHeight: CGFloat = 40
    static let textViewHeight: CGFloat = 80
    static let tagButtonHeight: CGFloat = 40
    static let horizontalMargin: CGFloat = 20
    static let inPutsMargin: CGFloat = 10
    static let saveButtonHeight: CGFloat = 50
  }
  
  lazy var user = Auth.auth().currentUser

  
  // MARK: Properties
  // TODO: 상태들은 감추고 외부에서 func로 일을 위임하는 것
  var markerLat: Double?
  var markerLng: Double?
  var tagSelected: Bool = false
  var selectedEnvironmentTags: [String] = []
  var selectedTypeTags: [String] = []
  var selectedFacilityTags: [String] = []
  
  private var capturedImageUrl: String?
  
  private let db = Firestore.firestore()
  
  let disposeBag = DisposeBag()
  
  
  // MARK: UI
  
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let mapView = NMFMapView()
  private let markerPinImageView = UIImageView(image: UIImage(named: "marker_Pin_Wind"))
  
  // 흡연구역 사진
  var areaImage = UIButton().then {
    $0.setImage(UIImage(systemName: "camera.on.rectangle.fill"), for: .normal)
    $0.layer.borderWidth = 0.5
    $0.layer.borderColor = UIColor.systemGray4.cgColor
    $0.layer.cornerRadius = 5
    $0.layer.masksToBounds = true
  }
  
  // 흡연구역 이름
  private let nameLabel = UILabel().then {
    $0.text = "구역 이름"
    $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
  }
  let nameTextField = UITextField().then {
    $0.placeholder = "강남역 11번 출구"
    $0.borderStyle = .roundedRect
    $0.font = UIFont.systemFont(ofSize: Metric.textfontSize)
  }
  
  // 흡연구역 설명
  private let descriptionLabel = UILabel().then {
    $0.text = "구역 설명"
    $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
  }
  let descriptionTextView = UITextView().then {
    $0.text = "우측으로 5m"
    $0.textColor = .systemGray3
    $0.layer.borderWidth = 0.5
    $0.layer.borderColor = UIColor.systemGray4.cgColor
    $0.layer.cornerRadius = 5
    $0.textContainerInset = UIEdgeInsets(top: 10, left: 3, bottom: 10, right: 3)
    $0.font = UIFont.systemFont(ofSize: Metric.textfontSize)
  }
  
  // 흡연구역 태그들
  private let environmentTags = ["실내", "실외", "밀폐형", "개방형"]
  private let typeTags = ["카페", "술집", "식당", "흡구", "노래방", "보드게임 카페", "당구장", "피시방"]
  private let facilityTags = ["재떨이", "의자", "별도 전담 구역", "라이터"]
  
  // 저장 버튼
  let saveButton = UIButton(type: .system).then {
    $0.setTitle("저장", for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.backgroundColor = .systemBlue
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 8
  }
  
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureUI()
    self.addSubView()
    self.defineFlexContainer()
    self.bindAreaImageButton()
    self.bindSaveButton()
  }
  
  
  // MARK: setup
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.scrollView.pin.all(self.view.pin.safeArea)
    self.contentView.pin.top().horizontally()

    self.contentView.flex.layout(mode: .adjustHeight)
    self.scrollView.contentSize = self.contentView.frame.size
    
    let mapCenter = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.midY)
    self.markerPinImageView.center = CGPoint(x: mapCenter.x, y: mapCenter.y - ( self.markerPinImageView.bounds.height / 2 ))
  }
  
  private func configureUI() {
    self.view.backgroundColor = .white
    self.navigationItem.title = "구역 등록"
    self.descriptionTextView.delegate = self
    self.mapView.allowsScrolling = false
  }
  
  private func addSubView() {
    self.view.addSubview(self.scrollView)
    self.scrollView.addSubview(self.contentView)
    self.mapView.addSubview(self.markerPinImageView)
  }
  
  
  // MARK: Layout
  
  private func defineFlexContainer() {
    self.contentView.flex
      .direction(.column)
      .define {
        //$0.addItem(self.mapView).height(Metric.mapHeight)
        $0.addItem(self.areaImage).height(Metric.imageSize).width(Metric.imageSize).marginLeft(Metric.imageMargin).marginTop(Metric.imageMargin)
        
        $0.addItem()
          .direction(.column)
          .paddingHorizontal(Metric.horizontalMargin)
          .define {
            $0.addItem(self.nameLabel).height(Metric.labelHeight)
            $0.addItem(self.nameTextField).height(Metric.textFieldHeight).marginBottom(10)
            $0.addItem(self.descriptionLabel).height(Metric.labelHeight)
            $0.addItem(self.descriptionTextView).height(Metric.textViewHeight).marginBottom(10)
          }
        
        $0.addItem(self.makeTagSection(title: "환경", tags: self.environmentTags))
          .paddingHorizontal(Metric.horizontalMargin)
        $0.addItem(self.makeTagSection(title: "유형", tags: self.typeTags))
          .paddingHorizontal(Metric.horizontalMargin)
        //facilityTags 임시 제거
        //$0.addItem(self.makeTagSection(title: "시설", tags: self.facilityTags))
          //.paddingHorizontal(Metric.horizontalMargin)

        $0.addItem(saveButton).height(Metric.saveButtonHeight).margin(Metric.horizontalMargin)
      }
  }
  
  private func makeTagSection(title: String, tags: [String]) -> UIView {
    let container = UIView()
    
    let titleLabel = UILabel().then {
      $0.text = title
      $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    }
    //TODO:
    container.flex
      .direction(.column)
      .define {
        $0.addItem(titleLabel).height(Metric.labelHeight)
        
        $0.addItem()
          .direction(.row)
          .wrap(.wrap)
          .define { flex in
            for tag in tags {
              // TODO: 추상화 레벨 맞추기
              let tagButton = UIButton().then {
                $0.setTitle(tag, for: .normal)
                $0.titleLabel?.font = .systemFont(ofSize: 14)
                $0.backgroundColor = .systemGray6
                $0.setTitleColor(.label, for: .normal)
                $0.layer.cornerRadius = 15
                $0.layer.borderWidth = 0.7
                $0.layer.borderColor = UIColor.systemGray4.cgColor
                $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
                $0.sizeToFit()
                
                let isSelected: Bool
                switch title {
                case "환경":
                  isSelected = self.selectedEnvironmentTags.contains(tag)
                case "유형":
                  isSelected = self.selectedTypeTags.contains(tag)
                case "시설":
                  isSelected = self.selectedFacilityTags.contains(tag)
                default:
                  isSelected = false
                }
                $0.isSelected = isSelected
                $0.backgroundColor = isSelected ? .gray : .systemGray6
                $0.setTitleColor(.label, for: .normal)
              }
              
              // Tap Event
              tagButton.rx.tap.bind { [weak self] in
                self?.onTapButton(tagButton)
              }.disposed(by: disposeBag)
              
              flex.addItem(tagButton)
                .height(Metric.tagButtonHeight)
                .margin(0, 0, 10, 10)
            }
          }
      }
    return container
  }
  
  
  // MARK: Button Actions
  
  private func onTapButton(_ sender: UIButton) {
    // 선택에 따른 토글 변경
    sender.isSelected.toggle()
    // 버튼 외관 업데이트 함수
    self.updateButtonAppearance(sender)
    // 해당 배열 업데이트 함수
    self.updateSeletedTags(sender)
    // 프린트로 디버깅
  }
  
  // 버튼 외관 업데이트 함수
  private func updateButtonAppearance(_ button: UIButton) {
    // true일 때
    // 배경 진하게
    // false 일 때
    // 배경 원래 색상
    button.backgroundColor = button.isSelected ? .gray : .systemGray6
  }
  
  
  // 해당 배열 업데이트 함수
  private func updateSeletedTags(_ button: UIButton) {
    guard let title = button.titleLabel?.text else { return }
    
    if self.environmentTags.contains(title) { // 환경 태그일 때
      self.updateTag(title: "환경", array: &self.selectedEnvironmentTags, buttonTitle: title) // 해당 배열 업데이트 함수
    } else if self.typeTags.contains(title) { // 유형 태그일 때
      self.updateTag(title: "유형", array: &self.selectedTypeTags, buttonTitle: title) // 해당 배열 업데이트 함수
    } else if self.facilityTags.contains(title) { // 시설 태그일 때
      self.updateTag(title: "시설", array: &self.selectedFacilityTags, buttonTitle: title) // 해당 배열 업데이트 함수
    }
  }
  
  // 해당 배열 업데이트 함수
  private func updateTag(title: String, array: inout [String], buttonTitle: String) {
    // TODO: inout 쓰지 말기
    if array.contains(buttonTitle) { // 배열에 해당 값이 있다면
      array = array.filter { $0 != buttonTitle } // 해당 배열에서 값 빼기
    } else { // 있으면
      array.append(buttonTitle) // 넣기
    }
    print(title, array)
  }
  
  
  // 카메라 버튼 탭
  
  private func bindAreaImageButton() {
    self.areaImage.rx.tap.subscribe(
      onNext: { [weak self] in
        print("카메라 버튼 눌림")
        self?.openCamera()
      })
    .disposed(by: disposeBag)
  }
  
  // 저장 버튼 탭
  
  private func bindSaveButton() {
    self.saveButton.rx.tap.subscribe(
      onNext: { [weak self] in
        self?.saveSmokingAreaInfo()
        self?.view.window?.rootViewController?.dismiss(animated: true)
      })
    .disposed(by: self.disposeBag)
  }
  
  
  private func saveSmokingAreaInfo() {
    guard
      let name = self.nameTextField.text, !name.isEmpty,
      let description = self.descriptionTextView.text, !description.isEmpty,
      let lat = self.markerLat,
      let lng = self.markerLng
    else {
      // Alert을 띄워서 사용자한테 알려주기
      let alert = UIAlertController(title: "입력 오류", message: "이름, 설명은 필수 입력 항목입니다.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "확인", style: .default))
      self.present(alert, animated: true)
      return
    }
    
    let currentTime = Timestamp(date: Date())
    
    let safeLat = String(format: "%.9f", lat)
    let safeLng = String(format: "%.9f", lng)
    let documentID = "\(safeLat)_\(safeLng)"
    
    // 모델로 만들기
    let smokingArea = SmokingArea(
      imageURL: capturedImageUrl,
      name: name,
      description: description,
      areaLat: lat,
      areaLng: lng,
      selectedEnvironmentTags: self.selectedEnvironmentTags,
      selectedTypeTags: self.selectedTypeTags,
      selectedFacilityTags: self.selectedFacilityTags,
      uploadUser: self.user?.email ?? "",
      uploadDate: currentTime
    )
    
    // Firestore 저장
    let docRef = db.collection("smokingAreas").document(documentID)
    
    docRef.getDocument { snapshot, error in
      if let error = error {
        print(error)
      }
      
      docRef.setData(smokingArea.asDictionary)
    }
  }
}


// MARK:  UITextViewDelegate

extension MarkerInfoInputViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    self.descriptionTextView.text = nil
    self.descriptionTextView.textColor = .label
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      self.descriptionTextView.text = "우측으로 5m"
      self.descriptionTextView.textColor = .systemGray3
    }
  }
}


extension MarkerInfoInputViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func openCamera() {
    let camera = UIImagePickerController()
    camera.sourceType = .camera
    camera.delegate = self
    present(camera, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    if let image = info[.originalImage] as? UIImage {
      self.areaImage.setImage(image, for: .normal)
      self.uploadImage(image)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func uploadImage(_ image: UIImage) {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
    let storageRef = Storage.storage().reference()
    let fileName = "smokingAreas/\(UUID().uuidString).jpg"
    let imageRef = storageRef.child(fileName)
    
    imageRef.putData(imageData, metadata: nil) { [weak self] _, error in
      if let error = error {
        print("이미지 업로드 실패", error)
        return
      }
      imageRef.downloadURL { url, _ in
        self?.capturedImageUrl = url?.absoluteString
        print("업로드 완료 : ", self?.capturedImageUrl)
      }
    }
  }
}
