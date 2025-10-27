//
//  SettingsViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 10/27/25.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import RxSwift
import PhotosUI
import FlexLayout
import PinLayout
import Then

final class SettingsViewController: UIViewController {
  
  private let rootContainer = UIView()
  private let disposeBag = DisposeBag()
  
  private let titleLabel = UILabel().then {
    $0.text = "설정"
    $0.font = .boldSystemFont(ofSize: 28)
    $0.textAlignment = .center
    $0.textColor = .black
  }
  
  private let profileImageView = UIImageView().then {
    $0.image = UIImage(systemName: "person.circle.fill")
    $0.tintColor = .systemGray4
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 50
    $0.layer.borderWidth = 2
    $0.layer.borderColor = UIColor.systemGreen.cgColor
    $0.layer.shadowColor = UIColor.systemGreen.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 6
    $0.layer.shadowOpacity = 0.3
  }
  
  private let changePhotoButton = UIButton().then {
    $0.setTitle("프로필 사진 변경", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .systemGreen
    $0.layer.cornerRadius = 10
    $0.layer.shadowColor = UIColor.systemGreen.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 6
    $0.layer.shadowOpacity = 0.3
  }
  
  private let nicknameLabel = UILabel().then {
    $0.text = "닉네임"
    $0.font = .systemFont(ofSize: 18, weight: .medium)
  }
  
  private let nicknameTextField = UITextField().then {
    $0.placeholder = "새 닉네임을 입력하세요"
    $0.borderStyle = .roundedRect
    $0.font = .systemFont(ofSize: 16)
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.systemGray5.cgColor
    $0.layer.cornerRadius = 8
    $0.clearButtonMode = .whileEditing
  }
  
  private let saveNicknameButton = UIButton().then {
    $0.setTitle("닉네임 저장", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .systemGreen
    $0.layer.cornerRadius = 10
    $0.layer.shadowColor = UIColor.systemGreen.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 6
    $0.layer.shadowOpacity = 0.3
  }
  
  private let deleteAccountButton = UIButton().then {
    $0.setTitle("회원 탈퇴", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .systemRed
    $0.layer.cornerRadius = 10
    $0.layer.shadowColor = UIColor.systemRed.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 6
    $0.layer.shadowOpacity = 0.3
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.view.addSubview(self.rootContainer)
    self.bindActions()
    self.layout()
    self.loadUserProfile()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.rootContainer.pin.all(self.view.pin.safeArea)
    self.rootContainer.flex.layout()
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
  }
  
  // MARK: - Layout
  private func layout() {
    self.rootContainer.flex.direction(.column).alignItems(.center).padding(20).define { flex in
      
      flex.addItem(self.titleLabel).marginBottom(30)
      
      flex.addItem(self.profileImageView)
        .size(100)
        .marginBottom(16)
      
      flex.addItem(self.changePhotoButton)
        .width(160)
        .height(44)
        .marginBottom(40)
      
      flex.addItem(self.nicknameLabel)
        .alignSelf(.start)
        .marginBottom(8)
      
      flex.addItem(self.nicknameTextField)
        .width(100%)
        .height(44)
        .marginBottom(16)
      
      flex.addItem(self.saveNicknameButton)
        .width(100%)
        .height(50)
        .marginBottom(40)
      
      flex.addItem(self.deleteAccountButton)
        .width(100%)
        .height(50)
    }
  }
  
  // MARK: - Load User Data
  private func loadUserProfile() {
    if let user = Auth.auth().currentUser {
      self.nicknameTextField.text = user.displayName
      if let photoURL = user.photoURL {
        self.profileImageView.kf.setImage(with: photoURL)
      }
    }
  }
  
  // MARK: - Actions
  private func bindActions() {
    self.changePhotoButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.presentImagePicker()
      })
      .disposed(by: self.disposeBag)
    
    self.saveNicknameButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.updateNickname()
      })
      .disposed(by: self.disposeBag)
    
    self.deleteAccountButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.confirmDeleteAccount()
      })
      .disposed(by: self.disposeBag)
  }
  
  private func presentImagePicker() {
    var config = PHPickerConfiguration(photoLibrary: .shared())
    config.filter = .images
    let picker = PHPickerViewController(configuration: config)
    picker.delegate = self
    self.present(picker, animated: true)
  }
  
  private func updateNickname() {
    guard let newName = self.nicknameTextField.text, !newName.isEmpty else { return }
    
    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
    changeRequest?.displayName = newName
    changeRequest?.commitChanges { error in
      if let error = error {
        print("닉네임 업데이트 실패:", error.localizedDescription)
      } else {
        print("닉네임 업데이트 성공:", newName)
      }
    }
  }
  
  private func confirmDeleteAccount() {
    let alert = UIAlertController(title: "회원 탈퇴", message: "정말 탈퇴하시겠습니까?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    alert.addAction(UIAlertAction(title: "탈퇴", style: .destructive, handler: { _ in
      self.deleteAccount()
    }))
    self.present(alert, animated: true)
  }
  
  private func deleteAccount() {
    Auth.auth().currentUser?.delete { error in
      if let error = error {
        print("회원 탈퇴 실패:", error.localizedDescription)
      } else {
        print("회원 탈퇴 완료")
        self.goHome()
      }
    }
  }
}

extension SettingsViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    
    guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
    provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
      guard let self = self, let image = image as? UIImage else { return }
      DispatchQueue.main.async {
        self.profileImageView.image = image
      }
    }
  }
}
