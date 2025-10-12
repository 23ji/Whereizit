//
//  SmokingAreaBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 8/31/25.
//

import FirebaseCore
import FirebaseStorage
import FlexLayout

import Kingfisher

import PinLayout
import Then

import UIKit

final class SmokingAreaBottomSheetViewController: UIViewController {
  
  private enum Metric {
    static let horizontalMargin: CGFloat = 20
    static let labelFontSize: CGFloat = 16
    static let labelHeight: CGFloat = 50
    static let tagButtonHeight: CGFloat = 40
    static let imageSize: CGFloat = 100
  }
  
  
  // MARK: UI Components
  
  private let rootFlexContainer = UIView()
  
  private let areaImageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
    $0.layer.cornerRadius = 8
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill // 이미지가 꽉 차도록 설정
  }
  
  private let nameLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 18, weight: .bold)
    $0.numberOfLines = 0
    $0.text = "장소 이름"
  }
  
  private let descriptionLabel = UITextView().then {
    $0.backgroundColor = .red
    $0.textColor = .systemGray
    $0.font = .systemFont(ofSize: 14)
    //$0.numberOfLines = 0
  }
  
  private var tagSections: [UIView] = []
  
  
  // MARK: LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.view.addSubview(self.rootFlexContainer)
    self.setupLayout()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.rootFlexContainer.pin.all(view.pin.safeArea)
    self.rootFlexContainer.flex.layout()
  }
  
  
  // MARK: Setup Layout
  
  private func setupLayout() {
    self.rootFlexContainer.flex.direction(.column).padding(Metric.horizontalMargin)
      .define {
        // 상단 이미지 + 이름/설명
        $0.addItem().direction(.row).alignItems(.start)
          .define {
            $0.addItem(self.areaImageView)
              .width(Metric.imageSize)
              .height(Metric.imageSize)
            
            $0.addItem().direction(.column).marginLeft(16).grow(1).shrink(1)
              .define {
                $0.addItem(self.nameLabel)
                $0.addItem(self.descriptionLabel)
                  .marginTop(4).grow(1).shrink(1).minHeight(80)
              }
          }
      }
  }
  
  
  // MARK: Public Method
  
  public func configure(with data: SmokingArea) {
    DispatchQueue.main.async {
      self.nameLabel.text = data.name
      self.descriptionLabel.text = data.description
      
      self.areaImageView.image = UIImage(named: "defaultImage")
      
      self.loadImage(from: data.imageURL)
      
      self.tagSections.forEach { $0.removeFromSuperview() }
      self.tagSections.removeAll()
      
      let envSection = self.makeTagSection(title: "환경", tags: data.selectedEnvironmentTags)
      let typeSection = self.makeTagSection(title: "유형", tags: data.selectedTypeTags)
      let facilitySection = self.makeTagSection(title: "시설", tags: data.selectedFacilityTags)
      
      self.tagSections = [envSection, typeSection, facilitySection].filter { !$0.subviews.isEmpty }
      
      for section in self.tagSections {
        self.rootFlexContainer.flex.addItem(section).marginTop(20)
      }
      
      self.rootFlexContainer.flex.layout()
    }
  }
  
  private func loadImage(from urlString: String?) {
    guard let urlString = urlString, let url = URL(string: urlString) else { return }
    self.areaImageView.kf.setImage(with: url)
  }

  
  private func makeTagSection(title: String, tags: [String]) -> UIView {
    // 태그가 없으면 뷰를 생성하지 않음
    guard !tags.isEmpty else {
      return UIView()
    }
    
    let container = UIView()
    
    let titleLabel = UILabel().then {
      $0.text = title
      $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    }
    
    container.flex.direction(.column).define { flex in
      flex.addItem(titleLabel).marginBottom(10) // 타이틀과 태그 사이 간격
      
      flex.addItem().direction(.row).wrap(.wrap).define { flex in
        for tag in tags {
          let tagButton = UIButton(type: .system).then {
            $0.setTitle(tag, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14)
            $0.backgroundColor = .systemGray6
            $0.setTitleColor(.label, for: .normal)
            $0.layer.cornerRadius = 15
            $0.layer.borderWidth = 0.7
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            $0.isUserInteractionEnabled = false // 클릭 방지
          }
          flex.addItem(tagButton).marginRight(8).marginBottom(8)
        }
      }
    }
    return container
  }
}
