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
  
  private let placeImageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
    $0.layer.cornerRadius = 8
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
  }
  
  private let nameLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 18, weight: .bold)
    $0.textColor = .black
    $0.text = "장소 이름"
  }
  
  private let descriptionLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14, weight: .regular)
    $0.textColor = .systemGray
    $0.text = "장소 설명 어쩌고 저쩌고"
  }
  
  // 환경, 유형 등을 그룹으로 묶기 위한 UI들
  private let environmentTitleLabel = createSectionTitleLabel(title: "환경")
  private let environmentTagStackView = createTagStackView()
  
  private let typeTitleLabel = createSectionTitleLabel(title: "유형")
  private let typeTagStackView = createTagStackView()
  
  // 전체 UI를 담을 메인 스택뷰
  private let mainStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 20
    $0.alignment = .fill
    $0.distribution = .fill
  }
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupLayout()
  }
  
  // MARK: - Setup Layout
  
  private func setupLayout() {
    // TODO: 힌트 1
    // UI 컴포넌트들을 스택뷰(StackView)를 사용하여 그룹화하고 레이아웃을 설정해주세요.
    // 1. 장소 이름(nameLabel)과 설명(descriptionLabel)을 묶는 수직 스택뷰를 만드세요.
    // 2. 장소 이미지(placeImageView)와 1번에서 만든 스택뷰를 묶는 수평 스택뷰를 만드세요. (정보 섹션)
    // 3. 환경 타이틀(environmentTitleLabel)과 환경 태그 스택뷰(environmentTagStackView)를 묶는 수직 스택뷰를 만드세요. (환경 섹션)
    // 4. 유형 타이틀(typeTitleLabel)과 유형 태그 스택뷰(typeTagStackView)를 묶는 수직 스택뷰를 만드세요. (유형 섹션)
    // 5. 위에서 만든 모든 섹션(2, 3, 4)을 메인 스택뷰(mainStackView)에 추가하세요.
    // 6. 마지막으로, view에 mainStackView를 추가하고 SnapKit을 사용해 오토레이아웃 제약조건을 설정해주세요.
  }
  
  // MARK: - Public Method
  
  public func configure(with data: SmokingArea) {
    // TODO: 힌트 2
    // HomeViewController에서 전달받은 SmokingArea 데이터로 UI를 업데이트 해주세요.
    // 1. nameLabel과 descriptionLabel의 text를 설정해주세요.
    // 2. 태그 스택뷰들(environmentTagStackView, typeTagStackView)에 기존 태그가 남아있을 수 있으니, 모두 제거해주세요. (재사용 대비)
    // 3. data에 있는 태그 배열(selectedEnvironmentTags, selectedTypeTags)을 반복문으로 돌면서,
    //    createTagLabel(text:) 헬퍼 메서드를 사용해 태그 라벨을 생성하고, 각 스택뷰에 추가해주세요.
  }
  
  
  // MARK:  Helper Methods (UI 생성)
  
  private static func createSectionTitleLabel(title: String) -> UILabel {
    // TODO: 힌트 3
    // 섹션의 제목(환경, 유형 등)으로 사용할 UILabel을 생성하고 설정하여 반환해주세요.
    // (글자 크기, 굵기, 색상 등)
    return UILabel() // 임시 반환
  }
  
  private static func createTagStackView() -> UIStackView {
    // TODO: 힌트 4
    // 태그들을 담을 수평 UIStackView를 생성하고 설정하여 반환해주세요.
    // (방향, 간격 등)
    return UIStackView() // 임시 반환
  }
  
  private func createTagLabel(text: String) -> UILabel {
    // TODO: 힌트 5
    // "실내", "의자 있음" 등 개별 태그로 사용할 UILabel을 생성하고 스타일을 적용하여 반환해주세요.
    // (배경색, 글자색, 모서리 둥글게 등)
    return UILabel() // 임시 반환
  }
}

