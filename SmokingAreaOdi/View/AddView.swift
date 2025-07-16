//
//  AddView.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/16/25.
//
import NMapsMap
import UIKit


final class AddView: UIView {
    let mapView = NMFMapView()
    let addButton = UIButton()
    
    
    // 초기화 메서드 (코드로 UI 작성 시 필수)
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupUI()              // UI 구성 메서드 호출
    }
    
    
    // storyboard 사용할 계획 없기 때문에 fatalError 처리
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
      
      //지도
      mapView.frame = bounds
      mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight] //크기 자동 조절
      addSubview(mapView)
    }
}
