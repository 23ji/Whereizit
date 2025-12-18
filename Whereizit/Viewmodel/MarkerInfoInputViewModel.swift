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
  struct Input {
    let name: BehaviorRelay<String>
    let description: BehaviorRelay<String>
    let selectedCategory: BehaviorRelay<String?>
    let environmentTags: BehaviorRelay<[String]>
    let typeTags: BehaviorRelay<[String]>
    let facilityTags: BehaviorRelay<[String]>
    let saveTapped: PublishRelay<Void>
  }
  
  struct Output {
    let isSaveEnabled: Driver<Bool>
    let tagsForSection: Driver<[String: [String]]>
    let saveResult: PublishRelay<Bool>
  }
}
