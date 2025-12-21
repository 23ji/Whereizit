//
//  MarkerInfoInputViewModel.swift
//  Whereizit
//
//  Created by 이상지 on 12/12/25.
//

import Foundation
import RxRelay
import RxCocoa

final class MarkerInfoInputViewModel {
  struct Input { // View -> ViewModel
    let name: BehaviorRelay<String> // BehaviorRelay : 초기값을 가지며 항상 최신값을 유지
    let description: BehaviorRelay<String>
    let selectedCategory: BehaviorRelay<String?>
    let environmentTags: BehaviorRelay<[String]>
    let typeTags: BehaviorRelay<[String]>
    let facilityTags: BehaviorRelay<[String]>
    let saveTapped: PublishRelay<Void> // PublishRelay : 구독 이후 이벤트만 처리하며 종료되지 않음
  }
  
  struct Output { // ViewModel -> View
    let isSaveEnabled: Driver<Bool>
    let tagsForSection: Driver<[String: [String]]>
    let saveResult: PublishRelay<Bool>
  }
}
