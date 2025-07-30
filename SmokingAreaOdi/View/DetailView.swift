//
//  DetailView.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/17/25.
//
import NMapsMap
import UIKit

import FlexLayout
import PinLayout   // 💡 FlexLayout 쓸 땐 PinLayout도 필요함
import Then        // 💡 선택사항 (지금은 사용 안함)

final class DetailView: UIView {
  
  // MARK: - Properties
  
  private let mapView = NMFMapView()
  private let rootFlexContainer = UIView()  // 💡 FlexLayout 루트 컨테이너로 사용할 뷰
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    // 1. 루트 Flex 컨테이너를 서브뷰로 추가
    addSubview(rootFlexContainer)
    
    // 2. FlexLayout으로 mapView 구성
    rootFlexContainer.flex.define { flex in
      flex.addItem(mapView).height(400)  // 💡 지도뷰 높이를 200 고정
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // 3. 레이아웃 적용
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // 💡 rootFlexContainer가 부모(self)에 꽉 차도록 배치
    rootFlexContainer.pin.all()
    
    // 💡 Flex 레이아웃 적용
    rootFlexContainer.flex.layout()
  }
}
