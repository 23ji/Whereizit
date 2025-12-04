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
    let categorySelection: Observable<String>
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

  private let disposeBag = DisposeBag()

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


  // MARK: Transform

  func transform(input: Input) -> Output {
    input.nameText
      .bind(to: self.nameRelay)
      .disposed(by: self.disposeBag)

    input.descriptionText
      .bind(to: self.descriptionRelay)
      .disposed(by: self.disposeBag)

    input.imageURL
      .bind(to: self.imageURLRelay)
      .disposed(by: self.disposeBag)

    return Output(
      initialData: .empty(),
      updateTagViews: .empty(),
      isSaveEnabled: .just(true),
      saveResult: .empty(),
      errorMessage: .empty()
    )

    input.categorySelection
      .subscribe(onNext: { [weak self] category in
        guard let self = self else { return }

        let current = self.categoryRelay.value
        let next = (current == category) ? nil : category
        self.categoryRelay.accept(next)

        self.selectedEnvTags.accept([])
        self.selectedFacTags.accept([])
        self.selectedTypeTags.accept([])
      })
      .disposed(by: self.disposeBag)

    input.tagSelection
      .subscribe(onNext: {[weak self] (section, tag) in
        guard let self = self else { return }

        switch section {
        case "환경": self.toggleTag(tag, in: self.selectedEnvTags)
        case "유형": self.toggleTag(tag, in: self.selectedTypeTags)
        case "시설": self.toggleTag(tag, in: self.selectedFacTags)
        default: break
        }
      })
  }


  private func toggleTag(_ tag: String, in relay: BehaviorRelay<Set<String>>) {
    var current = relay.value
    if current.contains(tag) {
      current.remove(tag)
    } else {
      current.insert(tag)
    }
    relay.accept(current)
  }
}
