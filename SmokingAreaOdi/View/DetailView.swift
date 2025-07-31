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
  
  // MARK: - Properties
  
  private let mapView = NMFMapView()
  private let rootFlexContainer = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(rootFlexContainer)
    rootFlexContainer.flex.direction(.column).define { flex in
      flex.addItem(mapView).height(300)
    }
  }
  
  // storyboard 사용할 계획 없기 때문에 fatalError 처리
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

    // rootFlexContainer 크기 지정 (전체 화면에 맞춤)
    rootFlexContainer.pin.all()

    // FlexLayout으로 하위 뷰들 배치
    rootFlexContainer.flex.layout()
  }
}
