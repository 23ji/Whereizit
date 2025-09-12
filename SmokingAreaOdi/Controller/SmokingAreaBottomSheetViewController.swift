//
//  SmokingAreaBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 8/31/25.
//

import FlexLayout
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
  }
  
  private let nameLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 18, weight: .bold)
    $0.numberOfLines = 0
    $0.text = "장소 이름"
  }
  
  private let descriptionLabel = UILabel().then {
    $0.textColor = .systemGray
    $0.font = .systemFont(ofSize: 14)
    $0.numberOfLines = 0
  }
  
  private var tagSections: [UIView] = []
  
  // MARK: LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    view.addSubview(rootFlexContainer)
    setupLayout()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    rootFlexContainer.pin.all(view.pin.safeArea)
    rootFlexContainer.flex.layout()
  }
  
  // MARK: Setup Layout
  
  private func setupLayout() {
    rootFlexContainer.flex.direction(.column).padding(Metric.horizontalMargin).define {
      // 상단 이미지 + 이름/설명
      $0.addItem().direction(.row).alignItems(.start)
        .define {
          $0.addItem(areaImageView)
            .width(Metric.imageSize)
            .height(Metric.imageSize)
          
          $0.addItem().direction(.column).marginLeft(16).grow(1).shrink(1)
            .define {
              $0.addItem(nameLabel)
              $0.addItem(descriptionLabel)
                .marginTop(4).grow(1).shrink(1).minHeight(20)
            }
        }
    }
  }
  
  
  // MARK: Public Method
  
  public func configure(with data: SmokingArea) {
    DispatchQueue.main.async {
      self.nameLabel.text = data.name
      self.descriptionLabel.text = data.description
      
      // 기존 태그 섹션 제거
      for section in self.tagSections {
        section.removeFromSuperview()
      }
      self.tagSections.removeAll()
      
      // 새로운 섹션 생성
      let envSection = self.makeTagSection(title: "환경", tags: data.selectedEnvironmentTags)
      let typeSection = self.makeTagSection(title: "유형", tags: data.selectedTypeTags)
      let facilitySection = self.makeTagSection(title: "시설", tags: data.selectedFacilityTags)
      
      self.tagSections = [envSection, typeSection, facilitySection]
      
      for section in self.tagSections {
        self.rootFlexContainer.flex.addItem(section).marginTop(20)
      }
      
      self.rootFlexContainer.flex.layout()
    }
  }
  
  
  private func makeTagSection(title: String, tags: [String]) -> UIView {
    let container = UIView()
    
    let titleLabel = UILabel().then {
      $0.text = title
      $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    }
    
    container.flex.direction(.column).define { flex in
      flex.addItem(titleLabel).height(Metric.labelHeight)
      
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
          }
          flex.addItem(tagButton)
            .margin(0, 0, 10, 10)
        }
      }
    }
    return container
  }
}
