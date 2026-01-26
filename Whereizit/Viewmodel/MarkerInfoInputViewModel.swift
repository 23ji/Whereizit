//
//  MarkerInfoInputViewModel.swift
//  Whereizit
//
//  Created by 이상지 on 12/12/25.
//

import Foundation

import FirebaseFirestore
import FirebaseStorage

import RxRelay
import RxSwift
import RxCocoa
import FirebaseAuth

final class MarkerInfoInputViewModel {

  struct AreaInput {
    let name: String?
    let description: String?
    let lat: Double?
    let lng: Double?
    let category: String?
    let finalImageURL: String?
    let environmentTags: [String]
    let typeTags: [String]
    let facilityTags: [String]
  }


  struct Input { // View -> ViewModel
    let saveData: Observable<AreaInput> // 구역 정보를 담은 데이터 스트림
    let savePhoto: Observable<Data>
  }

  struct Output { // ViewModel -> View
    let saveResult: PublishRelay<Bool> // ?
  }

  private var initialImageURL: String?
  var finalImageUrl: String?
  var imageUrl: String?
  private let disposeBag = DisposeBag()
  private let db = Firestore.firestore()


  init(initialImageURL: String? = nil) {
    self.initialImageURL = initialImageURL
  }


  func transform(input: Input) -> Output {
    let saveResult = PublishRelay<Bool>()

    input.saveData
      .subscribe(onNext: { [weak self] areaInput in
        self?.saveAreaData(areaInput: areaInput, resultRelay: saveResult)
      })
      .disposed(by: self.disposeBag)

    input.savePhoto
      .subscribe(onNext: { [weak self] data in
        self?.savePhoto(imageData: data)
      })
      .disposed(by: self.disposeBag)

    return Output(saveResult: saveResult)
  }


  private func saveAreaData(areaInput: AreaInput, resultRelay: PublishRelay<Bool>) {
    guard
      let name = areaInput.name, !name.isEmpty,
      let description = areaInput.description, !description.isEmpty,
          description != "우측으로 5m",
      let lat = areaInput.lat,
      let lng = areaInput.lng,
      let category = areaInput.category
    else {
      resultRelay.accept(false)
      return
    }

    let finalImageURL = areaInput.finalImageURL ?? self.initialImageURL

    let currentTime = Timestamp(date: Date())
    let userEmail = Auth.auth().currentUser?.email ?? "Unknown"

    let safeLat = String(format: "%.9f", lat)
    let safeLng = String(format: "%.9f", lng)
    let documentID = "\(safeLat)_\(safeLng)"

    let area = Area(
      documentID: documentID,
      imageURL: finalImageURL,
      name: name,
      description: description,
      areaLat: lat,
      areaLng: lng,
      category: category,
      selectedEnvironmentTags: areaInput.environmentTags,
      selectedTypeTags: areaInput.typeTags,
      selectedFacilityTags: areaInput.facilityTags,
      uploadUser: userEmail,
      uploadDate: currentTime
    )

    db.collection("smokingAreas").document(documentID).setData(area.asDictionary) { error in
      resultRelay.accept(error == nil)
    }
  }

  private func savePhoto(imageData: Data) {

    let storageRef = Storage.storage().reference()
    let fileName = "smokingAreas/\(UUID().uuidString).jpg"
    let imageRef = storageRef.child(fileName)

    print("연결됨@@@@@@@@@@@@@@@@@@@@@@@@22")
    imageRef.putData(imageData, metadata: nil) { [weak self] _, error in
      if let error = error {
        print("이미지 업로드 실패", error)
        return
      }
      imageRef.downloadURL { [weak self] url, error in
        if let error = error {
          print("다운로드 URL 가져오기 실패: \(error.localizedDescription)")
          return
        }

        guard let downloadURL = url else {
          print("다운로드 URL이 nil입니다")
          return
        }

//        print("업로드 완료 : ", self?.capturedImageUrl ?? "nil")

//        if ((self?.isEditMode) != nil),
//           let oldImageURL = self?.imageURL,
//           !oldImageURL.isEmpty,
//           oldImageURL != downloadURL.absoluteString {
//          self?.deleteOldImage(urlString: oldImageURL)
//        }
      }
    }
  }

  private func deleteOldImage(urlString: String) {
    guard let url = URL(string: urlString) else {
      print("잘못된 이미지 URL")
      return
    }

    let storageRef = Storage.storage().reference(forURL: urlString)
    storageRef.delete { error in
      if let error = error {
        print("기존 이미지 삭제 실패: \(error.localizedDescription)")
      } else {
        print("기존 이미지 삭제 성공: \(urlString)")
      }
    }
  }
}
