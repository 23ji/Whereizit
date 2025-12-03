//
//  MarkerInfoViewModel.swift
//  Whereizit
//
//  Created by 23ji on 12/4/25.
//

import FirebaseAuth
import FirebaseStorage

import RxSwift
import RxCocoa

import Foundation

final class MarkerInfoViewModel {

  struct Input {
    let nameText: Observable<String>
    let descriptionText: Observable<String>
    let cateforySelection: Observable<String>
    let tagSelection: Observable<(String, String)>
    let imageURL: Observable<String?>
    let saveTap: Observable<Void>
  }

  struct Output {
    let initialData: Driver<Area?>
    let updateTagViews: Driver<String>
    let isSaveEnabled: Driver<Bool>
    let saveResult: Signal<Bool>
    let errorMessage: Signal<String>
  }


  // MARK: Properties

  private let disposrBag = DisposeBag()
  private let mode: MarkerInfoInputViewController.InputMode

  private let nameRelay = BehaviorRelay<String>(value: "")
  private let descriptionRelay = BehaviorRelay<String>(value: "")
  private let imageURLRelay = BehaviorRelay<String?>(value: nil)

  private let categoryRelay = BehaviorRelay<String?>(value: nil)

  private var selectedEnvTags = BehaviorRelay<Set<String>>(value: [])
  private var selectedTypeTags = BehaviorRelay<Set<String>>(value: [])
  private var selectedFacTags = BehaviorRelay<Set<String>>(value: [])

  init(mode: MarkerInfoInputViewController.InputMode) {
    self.mode = mode

    if case let .edit(area) = mode {
      nameRelay.accept(area.name)
      descriptionRelay.accept(area.description)
      categoryRelay.accept(area.category)
      imageURLRelay.accept(area.imageURL)

      selectedEnvTags.accept(Set(area.selectedEnvironmentTags))
      selectedTypeTags.accept(Set(area.selectedTypeTags))
      selectedFacTags.accept(Set(area.selectedFacilityTags))
    }
  }
}
