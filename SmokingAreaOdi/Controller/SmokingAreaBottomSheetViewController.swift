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
  
  // MARK:  UI Components
  
  // UI 컴포넌트들을 담을 루트 컨테이너입니다.
  private let rootFlexContainer = UIView()
  
  private let areaImageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
  }
  
  private let nameLabel = UILabel().then {
    $0.textColor = .black
  }
  
  private let descriptionLabel = UILabel().then {
    $0.textColor = .systemGray
  }
  
  // 환경, 유형 등을 그룹으로 묶기 위한 UI들
  
  
  // MARK:  LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    // rootFlexContainer를 뷰에 추가합니다.
    self.view.addSubview(self.rootFlexContainer)
    // FlexLayout으로 레이아웃 구조를 정의합니다.
    self.setupLayout()
  }
  
  // PinLayout과 FlexLayout을 사용하여 실제 UI 위치를 계산하고 적용합니다.
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // TODO: 힌트 2
    // PinLayout을 사용하여 rootFlexContainer의 위치와 크기를 설정해주세요.
    // 1. rootFlexContainer를 safeArea에 맞춰 전체 화면으로 설정합니다. (예: .pin.all(view.pin.safeArea))
    self.rootFlexContainer.pin.all(self.view.pin.safeArea)
    // 2. rootFlexContainer의 flex 레이아웃을 계산하고 적용합니다. (예: .flex.layout())
    self.rootFlexContainer.flex.layout()
  }
  
  // MARK: - Setup Layout
  
  private func setupLayout() {
    // TODO: 힌트 1
    // FlexLayout의 `define` 클로저 안에서 UI 컴포넌트들의 계층 구조를 정의해주세요.
    // rootFlexContainer를 기준으로 세로(column) 방향으로 아이템을 배치합니다.
    
    // 예시 구조:
    rootFlexContainer.flex.direction(.column).padding(20).define { flex in
      // 1. 정보 섹션 (수평): .direction(.row)
      //    - 이미지 (placeImageView)
      //    - 이름/설명 그룹 (수직): .direction(.column)
      //        - 이름 (nameLabel)
      //        - 설명 (descriptionLabel)
      flex.addItem().direction(.row).define { flex in
        flex.addItem(self.areaImageView).width(100).height(100)
        
        flex.addItem().direction(.column).define {
          $0.addItem(self.nameLabel).width(30).height(20).marginLeft(20)
          $0.addItem(self.descriptionLabel).width(30).height(20).marginLeft(20)
        }
      }
      // 2. 환경 섹션 (수직): .direction(.column)
      //    - 환경 타이틀 (environmentTitleLabel)
      //    - 환경 태그 (environmentTagStackView)
      
      // 3. 유형 섹션 (수직): .direction(.column)
      //    - 유형 타이틀 (typeTitleLabel)
      //    - 유형 태그 (typeTagStackView)
      
      // 4. 시설 섹션 (수직): .direction(.column)
      //    - 유형 타이틀 (FacilityTitleLabel)
      //    - 유형 태그 (FacilityTagStackView)
    }
  }
  
  // MARK: - Public Method
  
  public func configure(with data: SmokingArea) {
    // TODO: 힌트 3
    // HomeViewController에서 전달받은 SmokingArea 데이터로 UI를 업데이트 해주세요.
    // 1. nameLabel과 descriptionLabel의 text를 설정해주세요.
    // 2. 태그 스택뷰들(environmentTagStackView, typeTagStackView)에 기존 태그가 남아있을 수 있으니, 모두 제거해주세요. (재사용 대비)
    // 3. data에 있는 태그 배열(selectedEnvironmentTags, selectedTypeTags)을 반복문으로 돌면서,
    //    createTagLabel(text:) 헬퍼 메서드를 사용해 태그 라벨을 생성하고, 각 스택뷰에 추가해주세요.
    
    // 데이터가 변경되었으므로, 레이아웃을 다시 계산하도록 알려줍니다.
    rootFlexContainer.flex.markDirty()
  }
  
  
  // MARK:  Helper Methods (UI 생성)
  
}

