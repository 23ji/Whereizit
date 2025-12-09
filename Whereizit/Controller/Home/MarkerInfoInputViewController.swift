//
//  MarkerInfoInputViewController.swift
//  Whereizit
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

import NVActivityIndicatorView

import NMapsMap

import RxSwift
import RxCocoa

import UIKit
import Kingfisher

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

  private var tagsDisposeBag = DisposeBag()

  private let viewModel: MarkerInfoViewModel

  private let imageURLRelay = PublishRelay<String?>() // 이미지 업로드 시 URL을 넘기는 통로
  private let tagSelectionRelay = PublishRelay<(String, String)>()

  private let uploadImage  = PublishRelay<Bool>()


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
    $0.imageView?.contentMode = .scaleAspectFill
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
  private let categoryTags = Constant.AppData.categories

  // 카테고리별 태그 정의
  private let categoryTagsMap = Constant.AppData.categoryTagsMap

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

  private let loadingIndicator = NVActivityIndicatorView(
    frame: .zero,
    type: .ballPulseSync,
    color: .systemGreen,
    padding: 0
  )

  var isSaveButtonEnabled: Bool = true {
    didSet {
      guard self.isSaveButtonEnabled != oldValue else { return }

      self.saveButton.isUserInteractionEnabled = self.isSaveButtonEnabled
      self.saveButton.isEnabled = self.isSaveButtonEnabled

      let backgroundColor: UIColor = self.isSaveButtonEnabled ? .systemBlue : .gray
      self.saveButton.backgroundColor = backgroundColor
    }
  }

  init(mode: InputMode) {
    self.inputMode = mode
    self.viewModel = MarkerInfoViewModel(mode: mode)
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
    //self.bindAreaImageButton()
    //self.bindSaveButton()

    //self.setupData(by: inputMode)

    self.bindViewModel()
    self.bindCameraAction()
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
    self.view.addSubview(self.loadingIndicator)

    self.loadingIndicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(50)
    }

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

              // rx.tap 바인딩은 bindViewModel에서 처리하므로 여기선 제거

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


  private func bindViewModel() {
    let categoryTap = Observable.merge(
      self.categoryButtons.map { button in
        button.rx.tap.map { button.titleLabel?.text ?? "" }
      }
    )

    let input = MarkerInfoViewModel.Input(
      nameText: self.nameTextField.rx.text.orEmpty.asObservable(),
      descriptionText: self.descriptionTextView.rx.text.orEmpty.asObservable(),
      categorySelection: categoryTap,
      tagSelection: self.tagSelectionRelay.asObservable(),
      imageURL: self.imageURLRelay.asObservable(),
      saveTap: self.saveButton.rx.tap.asObservable(),
      uploadImage:  self.uploadImage.asObservable()
    )

    let output = self.viewModel.transform(input: input)

    output.isUploadingImage
      .drive(onNext: { [weak self] isLoading in
        guard let self = self else { return }
        if isLoading {
          self.loadingIndicator.startAnimating()
          self.view.isUserInteractionEnabled = false
        } else {
          self.loadingIndicator.stopAnimating()
          self.view.isUserInteractionEnabled = true
        }
      })
      .disposed(by: self.disposeBag)

    output.initialData
      .drive(onNext: { [weak self] area in
        guard let self = self, let area = area else { return }

        self.nameTextField.text = area.name
        self.descriptionTextView.text = area.description
        self.descriptionTextView.textColor = .label

        if let urlString = area.imageURL, let url = URL(string: urlString) {
          self.areaImage.kf.setImage(with: url, for: .normal)
        }

        self.updateCategoryButtonAppearance(selectedCategory: area.category)
      })
      .disposed(by: self.disposeBag)

    output.updateTagViews
      .drive(onNext: {[weak self] (category, tags) in
        guard let self = self else { return }

        self.updateCategoryButtonAppearance(selectedCategory: category)

        self.updateTagSections(for: category, selectedTags: tags)
      })
      .disposed(by: self.disposeBag)

    output.isSaveEnabled
      .drive(onNext: { [weak self] isEnabled in
        guard let self = self else { return }
        self.saveButton.isEnabled = isEnabled
        self.saveButton.backgroundColor = isEnabled ? .systemBlue : .systemGray
      })
      .disposed(by: self.disposeBag)

    output.saveResult
      .emit(onNext: { [weak self] success in
        guard let self = self else { return }
        if success {
          self.dismiss(animated: true)
        }
      })
      .disposed(by: self.disposeBag)

    output.errorMessage
      .emit(onNext: { [weak self] message in
        guard let self = self else { return }
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
      })
      .disposed(by: self.disposeBag)
  }


  // MARK: UI Helpers

  private func updateCategoryButtonAppearance(selectedCategory: String) {
    self.categoryButtons.forEach { button in
      let isSelected = (button.titleLabel?.text == selectedCategory)
      // [수정] button.isSelected가 아닌, 계산된 isSelected 값을 사용합니다.
      button.isSelected = isSelected
      button.backgroundColor = isSelected ? .systemBlue : .systemGray6
      button.setTitleColor(isSelected ? .white : .label, for: .normal)
    }
  }

  private func updateTagButtonAppearance(_ button: UIButton) {
    button.backgroundColor = button.isSelected ? .gray : .systemGray6
    button.setTitleColor(button.isSelected ? .white : .label, for: .normal)
  }

  private func createButton(title: String) -> UIButton {
    let button = UIButton()
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 14)
    button.backgroundColor = .systemGray6
    button.setTitleColor(.label, for: .normal)
    button.layer.cornerRadius = 15
    button.layer.borderWidth = 0.7
    button.layer.borderColor = UIColor.systemGray4.cgColor
    button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    return button
  }

  // [수정] selectedTags 추가
  private func updateTagSections(for category: String, selectedTags: Set<String>) {
    self.tagsDisposeBag = DisposeBag()
    self.tagSectionContainer.subviews.forEach { $0.removeFromSuperview() }

    guard let tagData = self.categoryTagsMap[category] else { return }

    self.tagSectionContainer.flex
      .direction(.column)
      .define { flex in
        ["환경", "유형", "시설"].forEach { sectionTitle in
          if let tags = tagData[sectionTitle] {
            flex.addItem(self.makeTagSection(title: sectionTitle, tags: tags, selectedTags: selectedTags))
          }
        }
      }

    self.contentView.flex.layout(mode: .adjustHeight)
    self.scrollView.contentSize = self.contentView.frame.size
  }


  private func makeTagSection(title: String, tags: [String], selectedTags: Set<String>) -> UIView {
      let container = UIView()
      let titleLabel = UILabel().then {
          $0.text = title
          $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
      }

      container.flex.direction(.column).define { flex in
          flex.addItem(titleLabel).height(Metric.labelHeight)

          flex.addItem().direction(.row).wrap(.wrap).define { flex in
              for tag in tags {
                  let tagButton = self.createButton(title: tag)

                  if selectedTags.contains(tag) {
                    tagButton.isSelected = true
                    self.updateTagButtonAppearance(tagButton)
                  }

                  tagButton.rx.tap
                      .subscribe(onNext: { [weak self, weak tagButton] in
                          guard let self = self, let btn = tagButton else { return }
                          btn.isSelected.toggle()
                          self.updateTagButtonAppearance(btn)
                          self.tagSelectionRelay.accept((title, tag))
                      })
                      .disposed(by: self.tagsDisposeBag)

                  flex.addItem(tagButton)
                      .height(Metric.tagButtonHeight)
                      .margin(0, 0, 10, 10)
              }
          }
      }
      return container
  }
}


// MARK:  UITextViewDelegate

extension MarkerInfoInputViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == .systemGray3 {
      textView.text = nil
      textView.textColor = .label
    }
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "우측으로 5m"
      textView.textColor = .systemGray3
    }
  }
}


extension MarkerInfoInputViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func bindCameraAction() {
    self.areaImage.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.openCamera()
      })
      .disposed(by: self.disposeBag)
  }

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

    self.uploadImage.accept(true)
    
    let alert = UIAlertController(title: nil, message: "이미지 업로드 중...", preferredStyle: .alert)
    present(alert, animated: true)

    let storageRef = Storage.storage().reference()
    let fileName = "\(Constant.Storage.folderName)/\(UUID().uuidString).jpg"
    let imageRef = storageRef.child(fileName)

    imageRef.putData(imageData, metadata: nil) { [weak self] _, error in
      alert.dismiss(animated: true)

      if let error = error {
        print("이미지 업로드 실패", error)
        return
      }
      imageRef.downloadURL { [weak self] url, error in
        if let error = error {
          print("다운로드 URL 가져오기 실패: \(error.localizedDescription)")
          return
        }

        guard let downloadURL = url else { return }

        self?.imageURLRelay.accept(downloadURL.absoluteString)
        print("업로드 완료 : ", downloadURL.absoluteString)

        self?.uploadImage.accept(false)
      }
    }
  }
}
