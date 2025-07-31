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
  
  private let rootFlexContainer = UIView()
  private let mapView = NMFMapView()
  private let nameLabel = UILabel()
  private let nameTextField = UITextField()
  private let descriptionLabel = UILabel()
  private let descriptionTextField = UITextField()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(rootFlexContainer)
    rootFlexContainer.backgroundColor = .white
    
    setupInputs()
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    rootFlexContainer.pin.all()
    rootFlexContainer.flex.layout()
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
  
  private func setupLayout() {
    rootFlexContainer.flex.direction(.column).define { flex in
      flex.addItem(mapView).height(300)
      flex.addItem(nameLabel).height(50).marginHorizontal(20)
      flex.addItem(nameTextField).height(40).marginHorizontal(20)
      flex.addItem(descriptionLabel).height(50).marginHorizontal(20)
      flex.addItem(descriptionTextField).height(40).marginHorizontal(20)

    }
  }
}
