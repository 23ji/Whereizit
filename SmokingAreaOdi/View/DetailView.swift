//
//  DetailView.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/17/25.
//
import NMapsMap
import UIKit

import FlexLayout
import PinLayout
import Then

final class DetailView: UIView {

  private enum Metric {
    static let horizontalMargin: CGFloat = 20
  }

  private let rootFlexContainer = UIView()
  private let mapView = NMFMapView()
  private let nameLabel = UILabel()
  private let nameTextField = UITextField()
  private let descriptionLabel = UILabel()
  private let descriptionTextField = UITextField()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .white
    self.defineFlexContainer()

    self.setupInputs() // then
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.flex.layout()
  }
  
  private func setupInputs() {
    nameLabel.text = "흡연구역 이름"
    nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
    
    nameTextField.placeholder = "강남역 11번 출구"
    nameTextField.borderStyle = .roundedRect
    
    descriptionLabel.text = "흡연구역 설명"
    descriptionLabel.font = .systemFont(ofSize: 16, weight: .bold)
    
    descriptionTextField.placeholder = "우측으로 5m"
    descriptionTextField.borderStyle = .roundedRect
  }

  private func defineFlexContainer() {
    self.flex.addItem()
      .direction(.column)
      .alignItems(.stretch)
      .marginHorizontal(Metric.horizontalMargin)
      .define {
        $0.addItem(self.mapView).height(300)
        $0.addItem(self.nameLabel).height(50)
        $0.addItem(self.nameTextField).height(40)
        $0.addItem(self.descriptionLabel).height(50)
        $0.addItem(self.descriptionTextField).height(40)
      }
  }
}
