//
//  SmokingAreaTableViewCell.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 10/3/25.
//

import FirebaseCore
import FirebaseFirestore
import FlexLayout
import PinLayout
import Then

import UIKit


final class SmokingAreaTableViewCell: UITableViewCell {
  
  private let areaImageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
    $0.layer.cornerRadius = 8
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill // 이미지가 꽉 차도록 설정
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 18, weight: .medium)
  }
  
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.contentView.addSubview(self.areaImageView)
    self.contentView.addSubview(self.titleLabel)
    self.setupLayout()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.contentView.pin.all()
    self.contentView.flex.layout()
  }
  
  private func setupLayout() {
    contentView.flex.padding(10).define {
      $0.addItem(self.areaImageView)
      $0.addItem(self.titleLabel)
    }
  }
  
  func configure(with area: SmokingArea) {
    self.titleLabel.text = area.name
  }
  
  
}
