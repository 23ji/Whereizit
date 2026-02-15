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

  enum InputMode {
    case new(lat: Double, lng: Double)
    case edit(area: Area)
  }

  var mode: InputMode

  // MARK: - Constant Data
  let categoryTags = ["화장실", "쓰레기통", "물", "흡연구역"]

  let categoryTagsMap: [String: [String: [String]]] = [
    "화장실": [
      "환경": ["남녀 구분", "남녀 공용"],
      "유형": ["건물", "식당", "술집", "카페"],
      "시설": ["휴지", "비데"]
    ],
    "쓰레기통": [
      "환경": ["일반 쓰레기", "재활용 쓰레기"],
      "유형": ["실외", "실내"],
      "시설": ["분리수거"]
    ],
    "물": [
      "환경": ["실내", "실외"],
      "유형": ["정수기", "음수대", "약수터"],
      "시설": ["온수", "얼음"]
    ],
    "흡연구역": [
      "환경": ["실내", "실외", "밀폐형", "개방형"],
      "유형": ["흡연 구역", "카페", "술집", "식당", "노래방", "보드게임 카페", "당구장", "피시방"],
      "시설": ["별도 전자담배 구역", "의자", "라이터"]
    ]
  ]

  let selectedCategory = BehaviorRelay<String?>(value: nil)

  let selectedEnvironmentTags = BehaviorRelay<[String]>(value: [])
  let selectedTypeTags = BehaviorRelay<[String]>(value: [])
  let selectedFacilityTags = BehaviorRelay<[String]>(value: [])

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

    // 실시간 입력 이벤트 정의
    let nameText: Observable<String>
    let categorySelection: Observable<String>
    let tagSelection: Observable<String>
  }

  struct Output { // ViewModel -> View
    let saveResult: PublishRelay<Bool>

    let updateCategoryUI: Driver<String>
    let saveButtonEnabled: Driver<Bool>
  }

  private var initialImageURL: String?
  var finalImageUrl: String?
  var imageUrl: String?
  var capturedImageUrl: String?

  var markerLat: Double?
  var markerLng: Double?

  var isEditMode: Bool = false

  private let disposeBag = DisposeBag()
  private let db = Firestore.firestore()


  init(mode: InputMode, initialImageURL: String? = nil) {
    self.mode = mode
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

    // 임시값 넣어놓기
    return Output(
      saveResult: saveResult,
      updateCategoryUI: .empty(),
      saveButtonEnabled: .just(true)
    )
  }


  func updateCategory(category: String) {
    if self.selectedCategory.value == category {
      self.selectedCategory.accept(nil)

      self.selectedEnvironmentTags.accept([])
      self.selectedTypeTags.accept([])
      self.selectedFacilityTags.accept([])
    }
    else {
      self.selectedCategory.accept(category)

      self.selectedEnvironmentTags.accept([])
      self.selectedTypeTags.accept([])
      self.selectedFacilityTags.accept([])
    }
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
