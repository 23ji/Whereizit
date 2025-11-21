//
//  SmokingAreaTableViewCell.swift
//  Whereizit
//
//  Created by 23ji on 10/3/25.
//

import FirebaseCore
import FirebaseFirestore
import FlexLayout
import PinLayout
import Then

import UIKit
import CoreLocation


final class SmokingAreaTableViewCell: UITableViewCell {

  // TODO: Mark 구분하기
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
  
  private let distanceLabel = UILabel().then {
      $0.textColor = .systemGray
      $0.font = .systemFont(ofSize: 13, weight: .medium)
      $0.textAlignment = .right
  }
  
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.contentView.addSubview(self.areaImageView)
    self.contentView.addSubview(self.titleLabel)
    self.setupLayout()
  }
  
  required init?(coder: NSCoder) { fatalError() }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    self.contentView.flex.layout(mode: .adjustHeight)
    return self.contentView.frame.size
  }
  
  
  private func setupLayout() {
    self.contentView.flex
      .direction(.row)
      .alignItems(.center)
      .padding(10)
      .define {
        $0.addItem(self.areaImageView)
          .width(50)
          .height(50)
          .marginRight(12)
        $0.addItem(self.titleLabel)
          .grow(1)
        $0.addItem(self.distanceLabel)
          .width(60)
      }
  }
  
  
  private func loadImage(from urlString: String?) {
    if let urlString, let url = URL(string: urlString) {
      self.areaImageView.kf.setImage(with: url)
    } else {
      self.areaImageView.image = UIImage(named: Constant.defaultImage)
    }
  }
  
  
  func configure(with area: SmokingArea, currentLocation: CLLocation?) {
    self.titleLabel.text = area.name
    self.loadImage(from: area.imageURL)
    
    if let currentLocation = currentLocation {
      let areaLocation = CLLocation(latitude: area.areaLat, longitude: area.areaLng)
      let distanceInMeters = currentLocation.distance(from: areaLocation)
      
      if distanceInMeters < 1000 {
        self.distanceLabel.text = String(format: "%.0fm", distanceInMeters)
      } else {
        self.distanceLabel.text = String(format: "%.1fkm", distanceInMeters / 1000)
      }
    } else {
      self.distanceLabel.text = "-"
    }
  }

}
