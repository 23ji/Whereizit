//
//  MarkerInfoInputViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/17/25.
//
import FirebaseCore
import FirebaseFirestore
import FlexLayout
import IQKeyboardManagerSwift
import NMapsMap

import UIKit


class MarkerInfoInputViewController: UIViewController {
  
  let db = Firestore.firestore()
  
  // MARK: Constant
  private enum Metric {
    static let mapHeight: CGFloat = 200
    static let labelFontSize: CGFloat = 16
    static let labelHeight: CGFloat = 50
    static let textfontSize: CGFloat = 16
    static let textFieldHeight: CGFloat = 40
    static let textViewHeight: CGFloat = 80
    static let horizontalMargin: CGFloat = 20
    static let margin: CGFloat = 10
    static let saveButtonHeight: CGFloat = 50
  }
  
  // MARK: UI
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let mapView = NMFMapView()
  
  private let nameLabel = UILabel()
  private let nameTextField = UITextField()
  
  private let descriptionLabel = UILabel()
  private let descriptionTextView = UITextView()
  
  private let tagData: [String: [String]] = [
    "환경": ["실내", "실외", "밀폐형", "개방형"],
    "유형": ["카페", "술집", "피시방", "식당"],
    "시설": ["재떨이", "의자", "별도 전자담배 구역"]
  ]
  private var selectedTags: Set<String> = []
  
  private let saveButton = UIButton(type: .system)
  
  // MARK: Properties
  var lat: Double?
  var lng: Double?
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    self.view.addSubview(scrollView)
    self.scrollView.addSubview(contentView)
    
    setUI()
    setupInputs()
    defineFlexContainer()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.scrollView.pin.all(self.view.pin.safeArea)
    self.contentView.pin.top().horizontally()
    self.contentView.flex.layout(mode: .adjustHeight)
    self.scrollView.contentSize = contentView.frame.size
  }
  
  // MARK: UI Setup
  private func setUI() {
    self.navigationItem.title = "흡연구역 등록"
    
    self.saveButton.setTitle("저장", for: .normal)
    self.saveButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
    self.saveButton.backgroundColor = .systemBlue
    self.saveButton.setTitleColor(.white, for: .normal)
    self.saveButton.layer.cornerRadius = 8
    self.saveButton.addTarget(self, action: #selector(saveData), for: .touchUpInside)
  }
  
  private func setupInputs() {
    self.nameLabel.text = "흡연구역 이름"
    self.nameLabel.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    
    self.nameTextField.placeholder = "강남역 11번 출구"
    self.nameTextField.borderStyle = .roundedRect
    self.nameTextField.font = UIFont.systemFont(ofSize: Metric.textfontSize)
    
    self.descriptionLabel.text = "흡연구역 설명"
    self.descriptionLabel.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    
    self.descriptionTextView.delegate = self
    self.descriptionTextView.text = "우측으로 5m"
    self.descriptionTextView.textColor = .systemGray3
    self.descriptionTextView.layer.borderWidth = 0.5
    self.descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
    self.descriptionTextView.layer.cornerRadius = 5
    self.descriptionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 3, bottom: 10, right: 3)
    self.descriptionTextView.font = UIFont.systemFont(ofSize: Metric.textfontSize)
  }
  
  // MARK: Layout
  private func defineFlexContainer() {
    self.contentView.flex.direction(.column).define { flex in
      flex.addItem(mapView).height(Metric.mapHeight)
      
      flex.addItem().direction(.column).paddingHorizontal(Metric.horizontalMargin).define { inner in
        inner.addItem(nameLabel).height(Metric.labelHeight)
        inner.addItem(nameTextField).height(Metric.textFieldHeight).marginBottom(10)
        
        inner.addItem(descriptionLabel).height(Metric.labelHeight)
        inner.addItem(descriptionTextView).height(Metric.textViewHeight).marginBottom(10)
        
        for (category, tags) in tagData {
          let label = UILabel()
          label.text = category
          label.font = .boldSystemFont(ofSize: Metric.labelFontSize)
          inner.addItem(label).marginTop(Metric.margin).marginBottom(Metric.margin)
          
          inner.addItem().direction(.row).wrap(.wrap).define { tagFlex in
            for tag in tags {
              let button = makeTagButton(title: tag)
              tagFlex.addItem(button).marginRight(Metric.margin).marginBottom(Metric.margin)
            }
          }
        }
        
        // 저장 버튼
        inner.addItem(saveButton).height(Metric.saveButtonHeight).marginTop(20).marginBottom(40)
      }
    }
  }
  
  private func makeTagButton(title: String) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 14)
    button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    button.layer.cornerRadius = 16
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.systemGray4.cgColor
    button.backgroundColor = .systemGray6
    button.setTitleColor(.label, for: .normal)
    
    button.addAction(UIAction { [weak self] _ in
      self?.toggleTagSelection(tag: title, button: button)
    }, for: .touchUpInside)
    
    return button
  }
  
  private func toggleTagSelection(tag: String, button: UIButton) {
    if selectedTags.contains(tag) {
      selectedTags.remove(tag)
      button.backgroundColor = .systemGray6
      button.setTitleColor(.label, for: .normal)
    } else {
      selectedTags.insert(tag)
      button.backgroundColor = .systemBlue
      button.setTitleColor(.white, for: .normal)
    }
    print("선택된 태그: \(selectedTags)")
  }
  
  // MARK: Firebase 저장
  @objc private func saveData() {
    guard let lat = lat,
          let lng = lng,
          let name = nameTextField.text, !name.isEmpty,
          let description = descriptionTextView.text, !description.isEmpty else {
      print("필수값 누락")
      return
    }
    
    let data: [String: Any] = [
      "lat": lat,
      "lng": lng,
      "name": name,
      "description": description,
      "tags": Array(selectedTags),
      "createdAt": Timestamp(date: Date())
    ]
    
    db.collection("smokingAreas").addDocument(data: data) { error in
      if let error = error {
        print("저장 실패: \(error.localizedDescription)")
      } else {
        print("저장 성공")
        self.navigationController?.popToRootViewController(animated: true)
      }
    }
  }
}

// MARK: - UITextViewDelegate
extension MarkerInfoInputViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if descriptionTextView.textColor == .systemGray3 {
      descriptionTextView.text = nil
      descriptionTextView.textColor = .label
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if descriptionTextView.text.isEmpty {
      descriptionTextView.text = "우측으로 5m"
      descriptionTextView.textColor = .systemGray3
    }
  }
}
