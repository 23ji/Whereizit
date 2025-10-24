//
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
  
  private var tagSections: [UIView] = []
  
  
  // MARK: LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.view.addSubview(self.rootFlexContainer)
    self.setupLayout()
    self.bindActions()
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
  }
  
  
  // MARK: Public Method
  
  public func configure(with data: SmokingArea) {
    self.currentData = data
    
    DispatchQueue.main.async {
      self.nameLabel.text = data.name
      self.descriptionLabel.text = data.description
      
      self.areaImageView.image = UIImage(named: "defaultImage")
      
      self.loadImage(from: data.imageURL)
      
      let isMine = data.uploadUser == Auth.auth().currentUser?.email
      self.editButton.isHidden = !isMine
      self.deleteButton.isHidden = !isMine
      
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
  

  private func bindActions() {
    self.deleteButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let data = self?.currentData else { return }
        guard let documentID = data.documentID else { return }

        let alert = UIAlertController(title: "삭제", message: "등록한 흡연구역을 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .default))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { action in
          self?.db.collection("smokingAreas").document(documentID).delete { error in
            if let error = error {
              print("문서 삭제 실패:", error)
            } else {
              print("문서 삭제 성공")
              self?.dismiss(animated: true)
            }
          }
        })
        self?.present(alert, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    self.editButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self, let data = self.currentData else { return }
        
        let editVC = MarkerInfoInputViewController()
        editVC.modalPresentationStyle = .formSheet
        
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

//        editVC.saveButton.rx.tap
//          .subscribe(onNext: {
//            guard let documentID = data.documentID else { return }
//            
////            let updatedData: [String: Any] = [
////              "name": editVC.nameTextField.text ?? "",
////              "description": editVC.descriptionTextView.text ?? "",
////              "environmentTags": editVC.selectedEnvironmentTags,
////              "typeTags": editVC.selectedTypeTags,
////              "facilityTags": editVC.selectedFacilityTags,
////              "uploadDate": Timestamp(date: Date())
////            ]
//            
////            self.db.collection("smokingAreas").document(documentID).updateData(updatedData) { error in
////              if let error = error {
////                print("업데이트 실패:", error)
////              } else {
////                print("업데이트 성공")
////                self.dismiss(animated: true)
////              }
////            }
//          })
          //.disposed(by: self.disposeBag)
        
        self.present(editVC, animated: true)
      })
      .disposed(by: disposeBag)
  }

  
  private func loadImage(from urlString: String?) {
    guard let urlString = urlString, let url = URL(string: urlString) else { return }
    self.areaImageView.kf.setImage(with: url)
  }
  
  private func makeTagSection(title: String, tags: [String]) -> UIView {
    guard !tags.isEmpty else {
      return UIView()
    }
    
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
