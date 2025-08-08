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
  }
  
  // MARK: UI
  
  private let scrollView = UIScrollView() //스크롤 관련 코드 표시
  private let contentView = UIView() //
  
  private let mapView = NMFMapView()
  
  private let nameLabel = UILabel()
  private let nameTextField = UITextField()
  
  private let descriptionLabel = UILabel()
  private let descriptionTextView = UITextView()
  
  private let areaEnvironmentLabel = UILabel()
  private let areaTypeLabel = UILabel()
  private let areaFacilityLabel = UILabel()
  
  private let tagData: [String: [String]] = [
    "환경": ["실내", "실외", "밀폐형", "개방형"],
    "유형": ["카페", "술집", "피시방", "식당"],
    "시설": ["재떨이", "의자", "별도 전자담배 구역"]
  ]
  private var selectedTags: Set<String> = []
  
  // MARK: Properties
  
  var lat: Double?
  var lng: Double?
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(scrollView)//
    self.scrollView.addSubview(contentView)//
    print("내 마커 - 위도 : \(String(describing: lat)) 경도 : \(String(describing: lng))")
    self.setUI()
    self.setupInputs()
    self.defineFlexContainer()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.pin.all()//
    contentView.pin.top().horizontally()
    contentView.flex.layout(mode: .adjustHeight)//
    scrollView.contentSize = contentView.frame.size//
  }
  
  // MARK: UI Setup
  
  private func setUI() {
    self.navigationItem.title = "흡연구역 등록"
    self.view.backgroundColor = .white
  }
  
  private func setupInputs() {
    self.nameLabel.text = "흡연구역 이름"
    self.nameLabel.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    
    self.nameTextField.placeholder = "강남역 11번 출구"
    self.nameTextField.borderStyle = .roundedRect
    self.nameTextField.font = UIFont(name: nameTextField.font!.fontName, size: Metric.textfontSize)
    
    self.descriptionLabel.text = "흡연구역 설명"
    self.descriptionLabel.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    
    //Custom PlaceHolder
    self.descriptionTextView.delegate = self
    self.descriptionTextView.text = "우측으로 5m"
    self.descriptionTextView.textColor = .systemGray3
    self.descriptionTextView.layer.borderWidth = 0.5
    self.descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
    self.descriptionTextView.layer.cornerRadius = 5
    self.descriptionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 3, bottom: 10, right: 3)
    self.descriptionTextView.font = UIFont(name: nameTextField.font!.fontName, size: Metric.textfontSize)
  
    self.areaEnvironmentLabel.text = "환경"
    self.areaEnvironmentLabel.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    
    self.areaTypeLabel.text = "유형"
    self.areaTypeLabel.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    
    self.areaFacilityLabel.text = "시설"
    self.areaFacilityLabel.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
  }
  
  // MARK: Layout
  
  private func defineFlexContainer() {
    self.contentView.flex.direction(.column).define { flex in
      flex.addItem(mapView).height(Metric.mapHeight)
      
      flex.addItem().direction(.column).paddingHorizontal(Metric.horizontalMargin).define { inner in
        inner.addItem(self.nameLabel).height(Metric.labelHeight)
        inner.addItem(self.nameTextField).height(Metric.textFieldHeight).marginBottom(10)
        
        inner.addItem(self.descriptionLabel).height(Metric.labelHeight)
        inner.addItem(self.descriptionTextView).height(Metric.textViewHeight).marginBottom(10)
        
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
      }
    }
    /*
    self.contentView.flex.addItem()//
      .direction(.column)
      .alignItems(.stretch)
      .define {
        $0.addItem(self.mapView).height(Metric.mapHeight)
      }
    
    self.contentView.flex.addItem()//
      .direction(.column)
      .alignItems(.stretch)
      .marginHorizontal(Metric.horizontalMargin)
      .define {
        $0.addItem(self.nameLabel).height(Metric.labelHeight)
        $0.addItem(self.nameTextField).height(Metric.textFieldHeight).marginBottom(10)
        $0.addItem(self.descriptionLabel).height(Metric.labelHeight)
        $0.addItem(self.descriptionTextView).height(Metric.textViewHeight).marginBottom(10)
        $0.addItem(self.areaEnvironmentLabel).height(Metric.labelHeight)
        $0.addItem(self.areaTypeLabel).height(Metric.labelHeight)
        $0.addItem(self.areaFacilityLabel).height(Metric.labelHeight)
      }
     */
  }
  
  /*
   // MARK: Layout
   
   private func defineFlexContainer() {
   self.view.flex.direction(.column).define {
   $0.addItem(self.mapView).height(Metric.mapHeight)
   
   $0.addItem().direction(.column)
   .alignItems(.stretch)
   .marginHorizontal(Metric.horizontalMargin)
   .define {
   $0.addItem(self.nameLabel).height(Metric.labelHeight)
   $0.addItem(self.nameTextField).height(Metric.textFieldHeight)
   $0.addItem(self.descriptionLabel).height(Metric.labelHeight)
   $0.addItem(self.descriptionTextField).height(Metric.textFieldHeight)
   }
   }
   }
   */
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
}


//descriptionTextView에 PlaceHolder 효과
extension MarkerInfoInputViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    guard self.descriptionTextView.textColor == .systemGray3 else { return }
    self.descriptionTextView.text = nil
    self.descriptionTextView.textColor = .label
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if(self.descriptionTextView.text == ""){
      self.descriptionTextView.text = "우측으로 5m"
      self.descriptionTextView.textColor = .systemGray3
    }
  }
}
