//
//  SmokingAreaBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 8/31/25.
//

import SnapKit
import Then

import UIKit

final class SmokingAreaBottomSheetViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let placeImageView = UIImageView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        // TODO: 이미지 로딩 라이브러리(예: Kingfisher)로 이미지 설정
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
        // 1. 정보 섹션 (이미지 + 이름/설명) 구성
        let nameDescriptionStack = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel]).then {
            $0.axis = .vertical
            $0.spacing = 4
        }
        
        let topInfoStack = UIStackView(arrangedSubviews: [placeImageView, nameDescriptionStack]).then {
            $0.axis = .horizontal
            $0.spacing = 12
            $0.alignment = .center
        }
        placeImageView.snp.makeConstraints {
            $0.width.height.equalTo(60)
        }
        
        // 2. 환경 섹션 구성
        let environmentSectionStack = UIStackView(arrangedSubviews: [environmentTitleLabel, environmentTagStackView]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }
        
        // 3. 유형 섹션 구성
        let typeSectionStack = UIStackView(arrangedSubviews: [typeTitleLabel, typeTagStackView]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }
        
        // 4. 메인 스택뷰에 모든 섹션 추가
        [topInfoStack, environmentSectionStack, typeSectionStack].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        // 5. 뷰에 메인 스택뷰 추가 및 제약조건 설정
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - Public Method
    
    public func configure(with data: SmokingArea) {
        nameLabel.text = data.name
        descriptionLabel.text = data.description
        
        // 기존 태그들을 모두 지우고 새로 추가 (재사용을 위해)
        environmentTagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        data.selectedEnvironmentTags.forEach { tagName in
            let tagLabel = createTagLabel(text: tagName)
            environmentTagStackView.addArrangedSubview(tagLabel)
        }
        
        typeTagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        data.selectedTypeTags.forEach { tagName in
            let tagLabel = createTagLabel(text: tagName)
            typeTagStackView.addArrangedSubview(tagLabel)
        }
    }
    
    // MARK: - Helper Methods (UI 생성)
    
    private static func createSectionTitleLabel(title: String) -> UILabel {
        return UILabel().then {
            $0.text = title
            $0.font = .systemFont(ofSize: 13, weight: .semibold)
            $0.textColor = .darkGray
        }
    }
    
    private static func createTagStackView() -> UIStackView {
        return UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .leading
        }
    }

    private func createTagLabel(text: String) -> UILabel {
        return UILabel().then {
            $0.text = text
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .systemBlue
            $0.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            $0.layer.cornerRadius = 6
            $0.clipsToBounds = true
            // Inset을 주기 위해 별도의 PaddingLabel을 만들거나, 여기서는 간단하게 구현
            $0.textAlignment = .center
            // content hugging/compression resistance 설정
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            // 좌우 패딩을 위한 간단한 방법 (더 나은 방법은 Padding이 적용된 커스텀 UILabel 클래스 만들기)
            $0.text = " \(text) "
        }
    }
}
