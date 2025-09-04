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
    static let mapHeight: CGFloat = 200
    static let labelFontSize: CGFloat = 16
    static let labelHeight: CGFloat = 50
    static let tagButtonHeight: CGFloat = 40
    static let horizontalMargin: CGFloat = 20
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
    $0.text = "장소에 대한 설명입니다."
  }
  
  private var environmentTags: [String] = []
  
  private var tagSectionView: UIView?
  
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
    rootFlexContainer.flex.direction(.column).padding(Metric.horizontalMargin).define { flex in
      // 상단 이미지 + 이름/설명
      flex.addItem().direction(.row).alignItems(.center).define { flex in
        flex.addItem(areaImageView)
          .width(100)
          .height(100)
        
        flex.addItem()
          .direction(.column)
          .marginLeft(16)
          .grow(1)
          .shrink(1)
          .define {
            $0.addItem(nameLabel)
            $0.addItem(descriptionLabel).marginTop(4)
          }
      }
      
      // 태그 섹션 (나중에 configure에서 갱신 가능하도록 placeholder)
      tagSectionView = makeTagSection(title: "환경", tags: environmentTags)
      if let tagSectionView = tagSectionView {
        flex.addItem(tagSectionView)
          .marginTop(20)
      }
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
  
  // MARK: Public Method
  
  public func configure(with data: SmokingArea) {
    DispatchQueue.main.async {
      self.nameLabel.text = data.name
      self.descriptionLabel.text = data.description
      
      // 태그 데이터 업데이트
      self.environmentTags = data.selectedEnvironmentTags
      
      // 기존 태그 섹션 제거
      if let tagSectionView = self.tagSectionView {
        tagSectionView.removeFromSuperview()
      }
      
      // 새 태그 섹션 추가
      self.tagSectionView = self.makeTagSection(title: "환경", tags: self.environmentTags)
      if let tagSectionView = self.tagSectionView {
        self.rootFlexContainer.flex.addItem(tagSectionView)
          .marginTop(20)
      }
      
      // 레이아웃 갱신
      self.rootFlexContainer.flex.layout()
    }
  }
}
