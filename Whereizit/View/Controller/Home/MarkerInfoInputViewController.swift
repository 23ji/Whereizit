//
//  MarkerInfoInputViewController.swift
//  Whereizit
//
//  Created by 이상지 on 7/17/25.
//

import FirebaseAuth
import FirebaseCore
import FirebaseStorage

import FlexLayout
import Then

import IQKeyboardManagerSwift

import NMapsMap

import RxSwift
import RxCocoa

import UIKit

final class MarkerInfoInputViewController: UIViewController {


  enum InputMode {
    case new(lat: Double, lng: Double)
    case edit(area: Area)
  }


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

  var imageURL: String?
  var markerLat: Double?
  var markerLng: Double?
  var tagSelected: Bool = false
  var selectedEnvironmentTags: [String] = []
  var selectedTypeTags: [String] = []
  var selectedFacilityTags: [String] = []

  // 수정 모드 진입 시 초기 카테고리를 받기 위한 변수
  var initialCategory: String?

  private var editTarget: Area?
  private let inputMode: InputMode

  private var tagSectionContainer: UIView = UIView()
  private var categoryButtons: [UIButton] = []

  private var capturedImageUrl: String?
  private var selectedCategory: String?

  var isEditMode: Bool = false
  var existingDocumentID: String?

  let disposeBag = DisposeBag()

  let viewModel: MarkerInfoInputViewModel // 뷰모델을 프로퍼티로 가짐
  let savePhoto = PublishRelay<Data>()


  // MARK: UI

  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let mapView = NMFMapView()
  private let markerPinImageView = UIImageView(image: UIImage(named: "marker_Pin_Wind"))

  // 구역 사진
  var areaImage = UIButton().then {
    $0.setImage(UIImage(systemName: "camera.on.rectangle.fill"), for: .normal)
    $0.layer.borderWidth = 0.5
    $0.layer.borderColor = UIColor.systemGray4.cgColor
    $0.layer.cornerRadius = 5
    $0.layer.masksToBounds = true
  }

  // 구역 이름
  private let nameLabel = UILabel().then {
    $0.text = "구역 이름"
    $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
  }
  let nameTextField = UITextField().then {
    $0.placeholder = "강남역 11번 출구"
    $0.borderStyle = .roundedRect
    $0.font = UIFont.systemFont(ofSize: Metric.textfontSize)
  }

  // 구역 설명
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

  // 카테고리 태그
  private let categoryTags = ["화장실", "쓰레기통", "물", "흡연구역"]

  // 카테고리별 태그 정의
  private let categoryTagsMap: [String: [String: [String]]] = [
    "화장실": [
      "환경": ["남녀 구분", "남녀 공용"],
      "유형": ["건물", "식당", "술집", "카페"],
      "시설": ["휴지", "비데"]
    ],
    "쓰레기통": [
      "환경": ["일반 쓰레기", "재활용 쓰레기"],
      "유형": ["실외", "실내"],
      "시설": ["분리수거"]
    ],
    "물": [
      "환경": ["실내", "실외"],
      "유형": ["정수기", "음수대", "약수터"],
      "시설": ["온수", "얼음"]
    ],
    "흡연구역": [
      "환경": ["실내", "실외", "밀폐형", "개방형"],
      "유형": ["흡연 구역", "카페", "술집", "식당", "노래방", "보드게임 카페", "당구장", "피시방"],
      "시설": ["별도 전자담배 구역", "의자", "라이터"]
    ]
  ]

  // 저장 버튼
  let saveButton = UIButton(type: .system).then {
    $0.setTitle("저장", for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.backgroundColor = .systemBlue
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 8
    $0.isUserInteractionEnabled = true
    $0.isEnabled = true
  }


  init(mode: InputMode, viewModel: MarkerInfoInputViewModel) {
    self.inputMode = mode
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureUI()
    self.addSubView()
    self.defineFlexContainer()
    self.bindAreaImageButton()

    self.setupData(by: inputMode)

    self.bindViewModel()
  }


  private func bindViewModel() {

    let saveData = self.saveButton.rx.tap
      .map { [weak self] _ -> MarkerInfoInputViewModel.AreaInput in
        return MarkerInfoInputViewModel.AreaInput(
          name: self?.nameTextField.text,
          description: self?.descriptionTextView.text,
          lat: self?.markerLat,
          lng: self?.markerLng,
          category: self?.selectedCategory,
          finalImageURL: self?.capturedImageUrl ?? self?.imageURL,
          environmentTags: self?.selectedEnvironmentTags ?? [],
          typeTags: self?.selectedTypeTags ?? [],
          facilityTags: self?.selectedFacilityTags ?? []
        )
      }

    let viewModelInput = MarkerInfoInputViewModel.Input(
      saveData: saveData,
      savePhoto: self.savePhoto.asObservable()
    )

    self.savePhoto
      .subscribe(onNext: { data in
        print(data)
      })
      .disposed(by: self.disposeBag)

    let output = self.viewModel.transform(input: viewModelInput)

    output.saveResult
      .observe(on: MainScheduler.instance) //이후부터 하는 작업은 메인 스레드에서 (UI 작업이기 때문에)
      .subscribe(onNext: { [weak self] isSuccess in
        if isSuccess {
          self?.view.window?.rootViewController?.dismiss(animated: true)
        } else {
          print("저장 실패")
          let alert = UIAlertController(title: "알림", message: "이름/설명 입력과 카테고리 선택은 필수입니다.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
          })
          self?.present(alert, animated: true, completion: nil)
        }
      })
      .disposed(by: self.disposeBag)
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

        // 카테고리 섹션
        $0.addItem(self.makeCategorySection())
          .paddingHorizontal(Metric.horizontalMargin)
        $0.addItem(self.tagSectionContainer) // 카테고리 섹션 다음에 추가
          .paddingHorizontal(Metric.horizontalMargin)
        $0.addItem(saveButton).height(Metric.saveButtonHeight).margin(Metric.horizontalMargin)
      }
  }

  // 카테고리 섹션 생성
  private func makeCategorySection() -> UIView {
    let container = UIView()
    self.categoryButtons.removeAll()

    let titleLabel = UILabel().then {
      $0.text = "카테고리"
      $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    }

    container.flex
      .direction(.column)
      .define {
        $0.addItem(titleLabel).height(Metric.labelHeight)

        $0.addItem()
          .direction(.row)
          .wrap(.wrap)
          .define { flex in
            for category in self.categoryTags {
              let categoryButton = self.createCategoryButton(category)
              self.categoryButtons.append(categoryButton) // 버튼 저장

              categoryButton.rx.tap.bind { [weak self] in
                self?.onCategorySelected(categoryButton, category: category)
              }.disposed(by: disposeBag)

              flex.addItem(categoryButton)
                .height(Metric.tagButtonHeight)
                .margin(0, 0, 10, 10)
            }
          }
      }

    return container
  }


  // 카테고리 버튼 생성
  private func createCategoryButton(_ title: String) -> UIButton {
    let button = UIButton()
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 14)
    button.backgroundColor = .systemGray6
    button.setTitleColor(.label, for: .normal)
    button.layer.cornerRadius = 15
    button.layer.borderWidth = 0.7
    button.layer.borderColor = UIColor.systemGray4.cgColor
    button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    button.sizeToFit()
    return button
  }

  // 🛠️ UI 업데이트 로직
  // 카테고리 선택 시 호출 (사용자 탭)
  private func onCategorySelected(_ button: UIButton, category: String) {
    // 이미 선택된 카테고리를 다시 클릭한 경우
    if self.selectedCategory == category {
      // 선택 해제
      button.backgroundColor = .systemGray6
      button.setTitleColor(.label, for: .normal)
      self.selectedCategory = nil

      // 선택된 태그 초기화
      self.selectedEnvironmentTags.removeAll()
      self.selectedTypeTags.removeAll()
      self.selectedFacilityTags.removeAll()

      // 태그 섹션 제거
      self.tagSectionContainer.subviews.forEach { $0.removeFromSuperview() }
      self.contentView.flex.layout(mode: .adjustHeight)
      self.scrollView.contentSize = self.contentView.frame.size

      return
    }

    // 이전 선택 초기화
    self.resetCategorySelection()

    // 현재 선택 업데이트
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    self.selectedCategory = category

    // 사용자 탭 시에는 선택된 태그 초기화 (수정 모드 초기 세팅때는 이 함수 안탐)
    self.selectedEnvironmentTags.removeAll()
    self.selectedTypeTags.removeAll()
    self.selectedFacilityTags.removeAll()

    // 태그 섹션 업데이트
    self.updateTagSections(for: category)
  }

  // 카테고리 선택 초기화
  private func resetCategorySelection() {
    self.categoryButtons.forEach { button in
      button.backgroundColor = .systemGray6
      button.setTitleColor(.label, for: .normal)
    }
  }

  // 선택된 카테고리에 맞는 태그 섹션 표시
  private func updateTagSections(for category: String) {
    self.tagSectionContainer.subviews.forEach { $0.removeFromSuperview() }

    guard let tagData = self.categoryTagsMap[category] else { return }

    self.tagSectionContainer.flex
      .direction(.column)
      .define {
        if let environmentTags = tagData["환경"] {
          $0.addItem(self.makeTagSection(title: "환경", tags: environmentTags))
        }
        if let typeTags = tagData["유형"] {
          $0.addItem(self.makeTagSection(title: "유형", tags: typeTags))
        }
        if let facilityTags = tagData["시설"] {
          $0.addItem(self.makeTagSection(title: "시설", tags: facilityTags))
        }
      }

    // 레이아웃 업데이트
    self.contentView.flex.layout(mode: .adjustHeight)
    self.scrollView.contentSize = self.contentView.frame.size
  }

  private func makeTagSection(title: String, tags: [String]) -> UIView {
    let container = UIView()

    let titleLabel = UILabel().then {
      $0.text = title
      $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    }

    container.flex
      .direction(.column)
      .define {
        $0.addItem(titleLabel).height(Metric.labelHeight)

        $0.addItem()
          .direction(.row)
          .wrap(.wrap)
          .define { flex in
            for tag in tags {
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
              }

              // 수정 모드: 이미 선택된 태그인지 확인하여 UI 업데이트
              var isSelected = false
              switch title {
              case "환경":
                if self.selectedEnvironmentTags.contains(tag) { isSelected = true }
              case "유형":
                if self.selectedTypeTags.contains(tag) { isSelected = true }
              case "시설":
                if self.selectedFacilityTags.contains(tag) { isSelected = true }
              default: break
              }

              if isSelected {
                tagButton.isSelected = true
                self.updateButtonAppearance(tagButton)
              }

              tagButton.rx.tap.bind { [weak self] in
                self?.onTapButton(tagButton, sectionTitle: title)
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

  private func onTapButton(_ sender: UIButton, sectionTitle: String) {
    sender.isSelected.toggle()
    self.updateButtonAppearance(sender)
    self.updateSelectedTags(sender, sectionTitle: sectionTitle)
  }

  private func updateButtonAppearance(_ button: UIButton) {
    button.backgroundColor = button.isSelected ? .gray : .systemGray6
    // 선택되었을 때 텍스트 색상도 변경해주면 좋음 (선택: 흰색 / 미선택: 라벨색)
    button.setTitleColor(button.isSelected ? .white : .label, for: .normal)
  }

  private func updateSelectedTags(_ button: UIButton, sectionTitle: String) {
    guard let title = button.titleLabel?.text else { return }

    switch sectionTitle {
    case "환경":
      self.updateTag(title: "환경", array: &self.selectedEnvironmentTags, buttonTitle: title)
    case "유형":
      self.updateTag(title: "유형", array: &self.selectedTypeTags, buttonTitle: title)
    case "시설":
      self.updateTag(title: "시설", array: &self.selectedFacilityTags, buttonTitle: title)
    default:
      break
    }
  }

  private func updateTag(title: String, array: inout [String], buttonTitle: String) {
    if array.contains(buttonTitle) {
      array = array.filter { $0 != buttonTitle }
    } else {
      array.append(buttonTitle)
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


  private func setupData(by mode: InputMode) {
    switch mode {
    case let .new(lat, lng):
      self.isEditMode = false
      self.markerLat = lat
      self.markerLng = lng

    case let .edit(area):
      self.isEditMode = true
      self.imageURL = area.imageURL
      self.markerLat = area.areaLat
      self.markerLng = area.areaLng
      self.selectedEnvironmentTags = area.selectedEnvironmentTags
      self.selectedTypeTags = area.selectedTypeTags
      self.selectedFacilityTags = area.selectedFacilityTags

      if !area.category.isEmpty {
        self.initialCategory = area.category
      } else {
        self.initialCategory = nil
      }

      self.loadViewIfNeeded()
      self.nameTextField.text = area.name
      self.descriptionTextView.text = area.description
      if let url = URL(string: area.imageURL ?? "") {
        self.areaImage.kf.setImage(with: url, for: .normal)
      }

      self.setupEditModeUI()
    }
  }


  private func setupEditModeUI() {
    guard isEditMode else { return }
    guard let category = initialCategory else { return }

    if let categoryBtn = self.categoryButtons.first(where: { $0.titleLabel?.text == category }) {

      categoryBtn.backgroundColor = .systemBlue
      categoryBtn.setTitleColor(.white, for: .normal)
      self.selectedCategory = category

      self.updateTagSections(for: category)
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
    if let image = info[.originalImage] as? UIImage {
      self.areaImage.setImage(image, for: .normal)
      self.uploadImage(image)
    }

    picker.dismiss(animated: true, completion: nil)

  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }

  func uploadImage(_ image: UIImage) {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

    let alert = UIAlertController(title: nil, message: "이미지 업로드 중...", preferredStyle: .alert)
    present(alert, animated: true)

    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      alert.dismiss(animated: true)
    }

    self.savePhoto.accept(imageData)
    //
    //    let storageRef = Storage.storage().reference()
    //    let fileName = "smokingAreas/\(UUID().uuidString).jpg"
    //    let imageRef = storageRef.child(fileName)
    //
    //    imageRef.putData(imageData, metadata: nil) { [weak self] _, error in
    //      if let error = error {
    //        print("이미지 업로드 실패", error)
    //        return
    //      }
    //      imageRef.downloadURL { [weak self] url, error in
    //        if let error = error {
    //          print("다운로드 URL 가져오기 실패: \(error.localizedDescription)")
    //          return
    //        }
    //
    //        guard let downloadURL = url else {
    //          print("다운로드 URL이 nil입니다")
    //          return
    //        }
    //
    //        self?.isSaveButtonEnabled = true
    //
    //        self?.capturedImageUrl = downloadURL.absoluteString
    //        print("업로드 완료 : ", self?.capturedImageUrl ?? "nil")
    //
    //        if ((self?.isEditMode) != nil),
    //           let oldImageURL = self?.imageURL,
    //           !oldImageURL.isEmpty,
    //           oldImageURL != downloadURL.absoluteString {
    //          self?.deleteOldImage(urlString: oldImageURL)
    //        }
    //      }
  }
}

private func deleteOldImage(urlString: String) {
  guard let url = URL(string: urlString) else {
    print("잘못된 이미지 URL")
    return
  }

  let storageRef = Storage.storage().reference(forURL: urlString)
  storageRef.delete { error in
    if let error = error {
      print("기존 이미지 삭제 실패: \(error.localizedDescription)")
    } else {
      print("기존 이미지 삭제 성공: \(urlString)")
    }
  }
}
