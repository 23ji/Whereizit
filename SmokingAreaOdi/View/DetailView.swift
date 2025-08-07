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
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .white
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.flex.layout()
  }
  
  
 
}
