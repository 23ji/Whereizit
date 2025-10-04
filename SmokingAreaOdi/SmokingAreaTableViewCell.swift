//
//  SmokingAreaTableViewCell.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 10/3/25.
//

import FlexLayout
import PinLayout
import Then

import UIKit


final class SmokingAreaTableViewCell: UITableViewCell {
  
  private let nameLabel = UILabel()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.contentView.addSubview(self.nameLabel)
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
      $0.addItem(nameLabel)
    }
  }
  
  func configure(with text: String) {
    self.nameLabel.text = text
  }
}
