//
//  SettingsViewController.swift
//  Whereizit
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
  
  
  private func showToast(message: String, duration: TimeInterval = 3.0) {
    let toastLabel = UILabel().then {
      $0.backgroundColor = UIColor.black.withAlphaComponent(0.7)
      $0.textColor = .white
      $0.textAlignment = .center
      $0.font = .systemFont(ofSize: 14)
      $0.text = message
      $0.alpha = 0.0
      $0.layer.cornerRadius = 10
      $0.clipsToBounds = true
    }
    
    self.view.addSubview(toastLabel)
    toastLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      toastLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      toastLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
      toastLabel.widthAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, multiplier: 0.8),
      toastLabel.heightAnchor.constraint(equalToConstant: 40)
    ])
    
    UIView.animate(withDuration: 0.5, animations: {
      toastLabel.alpha = 1.0
    }) { _ in
      UIView.animate(withDuration: 0.5, delay: duration, options: [], animations: {
        toastLabel.alpha = 0.0
      }, completion: { _ in
        toastLabel.removeFromSuperview()
      })
    }
  }
  
  private func updateNickname() {
    guard let newName = self.nicknameTextField.text, !newName.isEmpty else { return }
    
    // 키보드 내리기
    self.nicknameTextField.resignFirstResponder()
    
    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
    changeRequest?.displayName = newName
    changeRequest?.commitChanges { [weak self] error in
      guard let self = self else { return }
      if let error = error {
        print("닉네임 업데이트 실패:", error.localizedDescription)
        self.showToast(message: " 닉네임 저장 실패 😢 ")
      } else {
        print("닉네임 업데이트 성공:", newName)
        self.showToast(message: " 닉네임이 저장되었어요 🎉 ")
      }
    }
  }
  
  private func updateProfileImage(_ image: UIImage) {
      guard let user = Auth.auth().currentUser,
            let imageData = image.jpegData(compressionQuality: 0.8) else { return }

      let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
      let metadata = StorageMetadata()
      metadata.contentType = "image/jpeg"

      storageRef.putData(imageData, metadata: metadata) { [weak self] metadata, error in
          guard let self = self else { return }
          if let error = error {
              print("이미지 업로드 실패:", error.localizedDescription)
              self.showToast(message: "프로필 저장 실패 😢")
              return
          }

          storageRef.downloadURL { url, error in
              if let error = error {
                  print("다운로드 URL 가져오기 실패:", error.localizedDescription)
                  self.showToast(message: "프로필 저장 실패 😢")
                  return
              }

              guard let url = url else { return }

              // Firebase Auth 프로필 업데이트
              let changeRequest = user.createProfileChangeRequest()
              changeRequest.photoURL = url
              changeRequest.commitChanges { error in
                  if let error = error {
                      print("프로필 사진 업데이트 실패:", error.localizedDescription)
                      self.showToast(message: " 프로필 저장 실패 😢 ")
                  } else {
                      print("프로필 사진 업데이트 성공")
                      self.profileImageView.kf.setImage(with: url) // 킹피셔로 표시
                      self.showToast(message: " 프로필 사진이 변경되었어요 🎉 ")
                  }
              }
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
        self.updateProfileImage(image) // 토스트 띄우기 포함
      }
    }
  }
}
