//
//  MarkerInfoInputViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/17/25.
//
import FirebaseCore
import FirebaseFirestore
import FlexLayout
import NMapsMap

import UIKit


class MarkerInfoInputViewController: UIViewController {
  
  let db = Firestore.firestore()
  // MARK: Constant
  
  private enum Metric {
    static let mapHeight: CGFloat = 300
    static let labelFontSize: CGFloat = 16
    static let labelHeight: CGFloat = 50
    static let textfontSize: CGFloat = 16
    static let textFieldHeight: CGFloat = 40
    static let textViewHeight: CGFloat = 80
    static let horizontalMargin: CGFloat = 20
  }
  
  // MARK: UI
  
  private let mapView = NMFMapView()
  private let nameLabel = UILabel()
  private let nameTextField = UITextField()
  private let descriptionLabel = UILabel()
  private let descriptionTextView = UITextView()
  
  // MARK: Properties
  
  var lat: Double?
  var lng: Double?
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("내 마커 - 위도 : \(String(describing: lat)) 경도 : \(String(describing: lng))")
    self.setUI()
    self.setupInputs()
    self.defineFlexContainer()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.view.flex.layout(mode: .fitContainer)
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
    self.descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    self.descriptionTextView.font = UIFont(name: nameTextField.font!.fontName, size: Metric.textfontSize)
  }
  
  // MARK: Layout
  
  private func defineFlexContainer() {
    self.view.flex.addItem()
      .direction(.column)
      .alignItems(.stretch)
      .define {
        $0.addItem(self.mapView).height(Metric.mapHeight)
      }
    
    self.view.flex.addItem()
      .direction(.column)
      .alignItems(.stretch)
      .marginHorizontal(Metric.horizontalMargin)
      .define {
        $0.addItem(self.nameLabel).height(Metric.labelHeight)
        $0.addItem(self.nameTextField).height(Metric.textFieldHeight)
        $0.addItem(self.descriptionLabel).height(Metric.labelHeight)
        $0.addItem(self.descriptionTextView).height(Metric.textViewHeight)
      }
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
