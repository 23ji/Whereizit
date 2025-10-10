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
    $0.image = UIImage(named: "defaultImage")
    $0.layer.borderWidth = 0.5
    $0.layer.borderColor = UIColor.systemGray5.cgColor
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
  
  override func prepareForReuse() {
    //self.areaImageView.image = nil
    self.titleLabel.text = nil
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.contentView.pin.all()
    self.contentView.flex.layout(mode: .adjustHeight)
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    self.contentView.pin.width(size.width)
    self.contentView.flex.layout(mode: .adjustHeight)
    return self.contentView.frame.size
  }
  
  
  private func setupLayout() {
    self.contentView.flex.direction(.row)
      .alignItems(.center)
      .padding(10)
      .define {
        $0.addItem(self.areaImageView)
          .width(50)
          .height(50)
          .marginRight(12)
        $0.addItem(self.titleLabel)
          .grow(1)
      }
  }
  
  
  private func loadImage(from urlString: String?) {
    guard let urlString = urlString, let url = URL(string: urlString) else { return }
    self.areaImageView.kf.setImage(with: url)
  }
  
  func configure(with area: SmokingArea) {
    self.titleLabel.text = area.name
    self.loadImage(from: area.imageURL)
  }
}
