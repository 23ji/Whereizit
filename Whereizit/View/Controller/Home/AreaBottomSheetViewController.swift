//
//  AreaBottomSheetViewController.swift
//  Whereizit
//
//  Created by 23ji on 8/31/25.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FlexLayout

import Kingfisher

import PinLayout
import SnapKit
import Then

import RxGesture
import RxSwift

import UIKit


final class AreaBottomSheetViewController: UIViewController {

  private enum Metric {
    static let horizontalMargin: CGFloat = 20
    static let labelFontSize: CGFloat = 16
    static let imageSize: CGFloat = 120
    static let cornerRadius: CGFloat = 16
  }


  // MARK: Components

  private var areaData: Area?
  private let db = Firestore.firestore()
  private let disposeBag = DisposeBag()
  private let rootFlexContainer = UIView()

  // 카테고리별 아이콘 매핑
  private let categoryIcons: [String: String] = [
    "화장실": "🚻",
    "쓰레기통": "🗑️",
    "물": "💧",
    "흡연구역": "🚬",
    "카테고리 없음": "❓" // 예외 처리용 아이콘
  ]

  // 카테고리별 색상 매핑
  private let categoryColors: [String: UIColor] = [
    "화장실": UIColor.systemPurple.withAlphaComponent(0.15),
    "쓰레기통": UIColor.systemGray.withAlphaComponent(0.15),
    "물": UIColor.systemCyan.withAlphaComponent(0.15),
    "흡연구역": UIColor.systemOrange.withAlphaComponent(0.15),
    "카테고리 없음": UIColor.systemGreen.withAlphaComponent(0.15)
  ]

  // 카테고리별 텍스트 색상 매핑
  private let categoryTextColors: [String: UIColor] = [
    "화장실": .toilet,
    "쓰레기통": .trash,
    "물": .water,
    "흡연구역": .smoking,
    "카테고리 없음": .systemGreen
  ]

  private let areaImageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
    $0.layer.cornerRadius = Metric.cornerRadius
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 2)
    $0.layer.shadowOpacity = 0.1
    $0.layer.shadowRadius = 8
  }

  private let nameLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 20, weight: .bold)
    $0.numberOfLines = 0
    $0.text = "장소 이름"
  }

  private let descriptionLabel = UITextView().then {
    $0.textColor = .darkGray
    $0.font = .systemFont(ofSize: 15)
    $0.isEditable = false
    $0.isScrollEnabled = false
    $0.textContainerInset = .zero
    $0.textContainer.lineFragmentPadding = 0
  }

  private let editButton = UIButton(type: .system).then {
    $0.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
    $0.tintColor = UIColor.lightGray
  }

  private let deleteButton = UIButton(type: .system).then {
    $0.setImage(UIImage(systemName: "trash.circle"), for: .normal)
    $0.tintColor = UIColor.lightGray
  }

  private let divider = UIView().then {
    $0.backgroundColor = .systemGray5
  }

  private let reportButton = UIButton().then {
    $0.setTitle("🚨 신고하기", for: .normal)
    $0.setTitleColor(.systemRed, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
  }

  private var categoryBadge: UIView?
  private var tagSections: [UIView] = []

  // 카테고리 배지를 담을 컨테이너
  private let categoryBadgeContainer = UIView()


  // MARK: LifeCycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.view.addSubview(self.rootFlexContainer)
    self.setupLayout()
    self.bindActions()
    self.bindImageTapGesture()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.rootFlexContainer.pin.all(view.pin.safeArea)
    self.rootFlexContainer.flex.layout()
  }


  // MARK: Setup Layout

  private func setupLayout() {
    self.rootFlexContainer.flex.direction(.column).padding(Metric.horizontalMargin)
      .define { flex in
        // 상단 이미지 + 이름/설명
        flex.addItem().direction(.row).alignItems(.start).paddingTop(10)
          .define { flex in
            flex.addItem(self.areaImageView)
              .width(Metric.imageSize)
              .height(Metric.imageSize)

            flex.addItem().direction(.column).marginLeft(16).grow(1).shrink(1)
              .define { flex in
                // 카테고리 배지 컨테이너 (이름 위로 이동)
                flex.addItem(self.categoryBadgeContainer)

                flex.addItem(self.nameLabel)
                flex.addItem(self.descriptionLabel)
                  .marginTop(8).grow(1).shrink(1).minHeight(70)
              }
          }

        // 버튼들
        flex.addItem().direction(.row).justifyContent(.end)
          .define { flex in
            flex.addItem(self.editButton).size(28)
            flex.addItem(self.deleteButton).size(28).marginLeft(12)
          }

        // 구분선
        flex.addItem(self.divider).height(1).marginVertical(20)
      }

    // 신고하기 버튼
    self.view.addSubview(reportButton)
    self.reportButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
    }
    self.reportButton.pin.center().bottom(view.pin.safeArea.bottom + 10)
  }


  // MARK: Public Method

  public func configure(with data: Area) {
    self.areaData = data

    DispatchQueue.main.async {
      self.nameLabel.text = data.name
      self.descriptionLabel.text = data.description
      self.areaImageView.image = UIImage(named: "defaultImage")
      self.loadImage(from: data.imageURL)

      let isMine = (data.uploadUser == Auth.auth().currentUser?.email)
      self.editButton.isHidden = !isMine
      self.deleteButton.isHidden = !isMine

      // 기존 카테고리 배지 제거 (컨테이너 비우기)
      self.categoryBadgeContainer.subviews.forEach { $0.removeFromSuperview() }
      self.categoryBadge = nil

      self.tagSections.forEach { $0.removeFromSuperview() }
      self.tagSections.removeAll()

      let categoryToDisplay: String
      if !data.category.isEmpty {
          categoryToDisplay = data.category
      } else {
          categoryToDisplay = "카테고리 없음"
      }

      // 카테고리 배지 생성
      let badge = self.makeSmallCategoryBadge(category: categoryToDisplay)
      self.categoryBadge = badge
      self.categoryBadgeContainer.flex.addItem(badge).marginBottom(6)
      self.categoryBadgeContainer.isHidden = false
      self.categoryBadgeContainer.flex.markDirty()


      let envSection = self.makeTagSection(title: "환경", tags: data.selectedEnvironmentTags, emoji: "📌")
      let typeSection = self.makeTagSection(title: "유형", tags: data.selectedTypeTags, emoji: "🗂️")
      let facilitySection = self.makeTagSection(title: "시설", tags: data.selectedFacilityTags, emoji: "🛠️")

      self.tagSections = [envSection, typeSection, facilitySection].filter { !$0.subviews.isEmpty }

      for section in self.tagSections {
        self.rootFlexContainer.flex.addItem(section).marginTop(16)
      }

      self.rootFlexContainer.flex.layout()
    }
  }

  // MARK: Actions
  private func bindActions() {

    //삭제 버튼
    self.deleteButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let data = self?.areaData else { return }
        guard let documentID = data.documentID else { return }

        let alert = UIAlertController(title: "삭제", message: "등록한 구역을 삭제하시겠습니까?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "취소", style: .default))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive) { _ in // .default -> .destructive
          self?.db.collection("smokingAreas").document(documentID).delete { error in
            print(error == nil ? "문서 삭제 성공" : "문서 삭제 실패: \(error!.localizedDescription)")
          }
        })
        self?.present(alert, animated: true)
      })
      .disposed(by: disposeBag)


    // 수정 버튼
    self.editButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        guard let data = self.areaData else { return }

        let editVC = MarkerInfoInputViewController(mode: .edit(area: data))
        
        editVC.modalPresentationStyle = .formSheet
        
        self.present(editVC, animated: true)
      })
      .disposed(by: disposeBag)
    

    // 🚨 신고하기 버튼 액션
    self.reportButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        guard let data = self.areaData else { return }

        let reportReasons = [
          "잘못된 위치",
          "잘못된 정보",
          "중복 등록",
          "부적절한 사진",
          "기타 (직접 입력)"
        ]

        let actionSheet = UIAlertController(title: "🚨 신고하기",
                                            message: "신고 사유를 선택해주세요",
                                            preferredStyle: .actionSheet)

        for reason in reportReasons {
          actionSheet.addAction(UIAlertAction(title: reason, style: .default, handler: { [weak self] _ in
            if reason == "기타 (직접 입력)" {
              let inputAlert = UIAlertController(title: "직접 입력", message: "신고 사유를 입력해주세요", preferredStyle: .alert)
              inputAlert.addTextField { $0.placeholder = "예: 구역이 사라졌어요" }
              inputAlert.addAction(UIAlertAction(title: "취소", style: .cancel))
              inputAlert.addAction(UIAlertAction(title: "신고", style: .destructive, handler: { [weak self] _ in
                let customReason = inputAlert.textFields?.first?.text ?? ""
                self?.submitReport(data: data, reason: customReason)
              }))
              self?.present(inputAlert, animated: true)
            } else {
              self?.submitReport(data: data, reason: reason)
            }
          }))
        }

        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))

        if let popover = actionSheet.popoverPresentationController {
          popover.sourceView = self.reportButton
          popover.sourceRect = self.reportButton.bounds
        }

        self.present(actionSheet, animated: true)
      })
      .disposed(by: disposeBag)
  }


  private func submitReport(data: Area, reason: String) {
    db.collection("reports").addDocument(data: [
      "reportedAreaID": data.documentID ?? "unknown",
      "reportedName": data.name,
      "reportedBy": Auth.auth().currentUser?.email ?? "unknown",
      "reason": reason.isEmpty ? "기타" : reason,
      "timestamp": Timestamp()
    ]) { error in
      let message = (error == nil)
      ? "신고가 접수되었습니다. 검토 후 조치하겠습니다."
      : "신고 중 오류가 발생했습니다."

      let resultAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      resultAlert.addAction(UIAlertAction(title: "확인", style: .default))
      self.present(resultAlert, animated: true)
    }
  }

  private func bindImageTapGesture() {
    self.areaImageView.isUserInteractionEnabled = true // 탭 인식 활성화
    self.areaImageView.rx.tapGesture()
      .when(.recognized)
      .subscribe(onNext: { _ in
        let imageVC = FullImageViewController(image: self.areaImageView.image)
        imageVC.modalPresentationStyle = .fullScreen
        imageVC.modalTransitionStyle = .crossDissolve
        self.present(imageVC, animated: true)
      })
      .disposed(by: disposeBag)
  }


  private func loadImage(from urlString: String?) {
    guard let urlString = urlString else { return }
    guard let url = URL(string: urlString) else { return }

    self.areaImageView.kf.setImage(with: url)
  }


  // 작은 카테고리 배지 생성
  private func makeSmallCategoryBadge(category: String) -> UIView {
    let container = UIView()

    let icon = categoryIcons[category] ?? "📍"
    let bgColor = categoryColors[category] ?? UIColor.systemGray6
    let textColor = categoryTextColors[category] ?? UIColor.label

    let badgeView = UIView().then {
      $0.backgroundColor = bgColor
      $0.layer.cornerRadius = 8
      $0.layer.borderWidth = 1.0
      $0.layer.borderColor = textColor.withAlphaComponent(0.3).cgColor
    }

    let iconLabel = UILabel().then {
      $0.text = icon
      $0.font = .systemFont(ofSize: 14)
    }

    let categoryLabel = UILabel().then {
      $0.text = category
      $0.font = .systemFont(ofSize: 13, weight: .bold)
      $0.textColor = textColor
    }

    container.flex.alignSelf(.start).define { flex in
      flex.addItem(badgeView)
        .direction(.row)
        .alignItems(.center)
        .padding(4, 8, 4, 8)
        .define { flex in
          flex.addItem(iconLabel)
          flex.addItem(categoryLabel).marginLeft(4)
        }
    }
    return container
  }

  private func makeTagSection(title: String, tags: [String], emoji: String) -> UIView {
    guard !tags.isEmpty else { return UIView() }
    let container = UIView()

    let headerView = UIView()
    let emojiLabel = UILabel().then {
      $0.text = emoji
      $0.font = .systemFont(ofSize: 18)
    }
    let titleLabel = UILabel().then {
      $0.text = title
      $0.font = .systemFont(ofSize: 17, weight: .semibold)
      $0.textColor = .label
    }

    headerView.flex.direction(.row).alignItems(.center).define { flex in
      flex.addItem(emojiLabel)
      flex.addItem(titleLabel).marginLeft(6)
    }

    container.flex.direction(.column).define { flex in
      flex.addItem(headerView).marginBottom(12)
      flex.addItem().direction(.row).wrap(.wrap).define { flex in
        for tag in tags {
          let tagView = self.makeModernTag(text: tag)
          flex.addItem(tagView).marginRight(8).marginBottom(8)
        }
      }
    }
    return container
  }

  private func makeModernTag(text: String) -> UIView {
    let container = UIView()

    let label = UILabel().then {
      $0.text = text
      $0.font = .systemFont(ofSize: 14, weight: .medium)
      $0.textColor = .gray
    }

    container.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
    container.layer.cornerRadius = 10
    container.layer.borderWidth = 1
    container.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor

    container.flex
      .padding(8, 14, 8, 14)
      .define { flex in
        flex.addItem(label)
      }

    return container
  }
}
