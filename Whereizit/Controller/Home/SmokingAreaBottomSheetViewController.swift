//  SmokingAreaBottomSheetViewController.swift
//  SmokingAreaOdi
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
import Then

import RxGesture
import RxSwift

import UIKit


final class SmokingAreaBottomSheetViewController: UIViewController {
  
  private enum Metric {
    static let horizontalMargin: CGFloat = 20
    static let labelFontSize: CGFloat = 16
    static let imageSize: CGFloat = 100
  }
  
  
  // MARK: Components
  
  private var currentData: SmokingArea?
  private let db = Firestore.firestore()
  private let disposeBag = DisposeBag()
  private let rootFlexContainer = UIView()
  
  private let areaImageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
  }
  
  private let nameLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 18, weight: .bold)
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
    $0.setImage(UIImage(systemName: "pencil"), for: .normal)
    $0.tintColor = .darkGray
  }
  
  private let deleteButton = UIButton(type: .system).then {
    $0.setImage(UIImage(systemName: "trash"), for: .normal)
    $0.tintColor = .systemRed
  }
  
  private let divider = UIView().then {
    $0.backgroundColor = .systemGray5
  }

  private let reportButton = UIButton().then {
      $0.setTitle("🚨 신고하기", for: .normal)
      $0.setTitleColor(.systemRed, for: .normal)
      $0.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
  }
  
  private var tagSections: [UIView] = []
  
  
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
                flex.addItem(self.nameLabel)
                flex.addItem(self.descriptionLabel)
                  .marginTop(8).grow(1).shrink(1).minHeight(70)
              }
          }
        
        // 버튼들
        flex.addItem().direction(.row).justifyContent(.end).marginTop(16).marginBottom(16)
          .define { flex in
            flex.addItem(self.editButton).size(22)
            flex.addItem(self.deleteButton).size(22).marginLeft(8)
          }
        
        // 구분선
        flex.addItem(self.divider).height(1)
      }
    self.view.addSubview(reportButton)
    self.reportButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
    }
  }
  
  
  // MARK: Public Method
  
  public func configure(with data: SmokingArea) {
    self.currentData = data
    
    DispatchQueue.main.async {
      self.nameLabel.text = data.name
      self.descriptionLabel.text = data.description
      self.areaImageView.image = UIImage(named: "defaultImage")
      self.loadImage(from: data.imageURL)
      
      let isMine = (data.uploadUser == Auth.auth().currentUser?.email)
      self.editButton.isHidden = !isMine
      self.deleteButton.isHidden = !isMine
      
      self.tagSections.forEach { $0.removeFromSuperview() }
      self.tagSections.removeAll()
      
      let envSection = self.makeTagSection(title: "환경", tags: data.selectedEnvironmentTags)
      let typeSection = self.makeTagSection(title: "유형", tags: data.selectedTypeTags)
      //facilitySection 임시 제거
      //let facilitySection = self.makeTagSection(title: "시설", tags: data.selectedFacilityTags)

      //self.tagSections = [envSection, typeSection, facilitySection].filter { !$0.subviews.isEmpty }
      self.tagSections = [envSection, typeSection].filter { !$0.subviews.isEmpty }
      
      for section in self.tagSections {
        self.rootFlexContainer.flex.addItem(section).marginTop(20)
      }
      
      self.rootFlexContainer.flex.layout()
    }
  }

  // MARK: Actions
  private func bindActions() {
    
    //삭제 버튼
    self.deleteButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let data = self?.currentData,
              let documentID = data.documentID else { return }

        let alert = UIAlertController(title: "삭제", message: "등록한 구역을 삭제하시겠습니까?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "취소", style: .default))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
          self?.db.collection("smokingAreas").document(documentID).delete { error in
            print(error == nil ? "문서 삭제 성공" : "문서 삭제 실패: \(error!.localizedDescription)")
            self?.dismiss(animated: true)
          }
        })
        self?.present(alert, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 수정 버튼
    self.editButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self, let data = self.currentData else { return }
        let editVC = MarkerInfoInputViewController()
        editVC.modalPresentationStyle = .formSheet
        editVC.isEditMode = true
        editVC.imageURL = data.imageURL
        editVC.markerLat = data.areaLat
        editVC.markerLng = data.areaLng
        editVC.selectedEnvironmentTags = data.selectedEnvironmentTags
        editVC.selectedTypeTags = data.selectedTypeTags
        editVC.selectedFacilityTags = data.selectedFacilityTags
        editVC.loadViewIfNeeded()
        editVC.nameTextField.text = data.name
        editVC.descriptionTextView.text = data.description
        if let url = URL(string: data.imageURL ?? "") {
          editVC.areaImage.kf.setImage(with: url, for: .normal)
        }
        self.present(editVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 🚨 신고하기 버튼 액션
    self.reportButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self, let data = self.currentData else { return }
        
        // 1️⃣ 신고 사유 목록 정의
        let reportReasons = [
          "잘못된 위치",
          "잘못된 정보",
          "중복 등록",
          "부적절한 사진",
          "기타 (직접 입력)"
        ]
        
        // 2️⃣ Action Sheet로 항목 선택
        let actionSheet = UIAlertController(title: "🚨 신고하기",
                                            message: "신고 사유를 선택해주세요",
                                            preferredStyle: .actionSheet)
        
        // 각 신고 항목 버튼 추가
        for reason in reportReasons {
          actionSheet.addAction(UIAlertAction(title: reason, style: .default, handler: { [weak self] _ in
            if reason == "기타 (직접 입력)" {
              // 기타 입력 Alert 띄우기
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
        
        // 취소 버튼
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        // iPad 대응 (ActionSheet 크래시 방지)
        if let popover = actionSheet.popoverPresentationController {
          popover.sourceView = self.reportButton
          popover.sourceRect = self.reportButton.bounds
        }
        
        self.present(actionSheet, animated: true)
      })
      .disposed(by: disposeBag)

  }
  
  
  private func submitReport(data: SmokingArea, reason: String) {
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
    guard let urlString = urlString, let url = URL(string: urlString) else { return }
    self.areaImageView.kf.setImage(with: url)
  }
  
  private func makeTagSection(title: String, tags: [String]) -> UIView {
    guard !tags.isEmpty else { return UIView() }
    let container = UIView()
    let titleLabel = UILabel().then {
      $0.text = title
      $0.font = .systemFont(ofSize: Metric.labelFontSize, weight: .bold)
    }
    container.flex.direction(.column).define { flex in
      flex.addItem(titleLabel).marginBottom(12)
      flex.addItem().direction(.row).wrap(.wrap).define { flex in
        for tag in tags {
          let tagButton = UIButton(type: .system).then {
            $0.setTitle(tag, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14)
            $0.backgroundColor = .systemGray6
            $0.setTitleColor(.label, for: .normal)
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 0.7
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            $0.isUserInteractionEnabled = false
          }
          flex.addItem(tagButton).marginRight(8).marginBottom(8)
        }
      }
    }
    return container
  }
}
