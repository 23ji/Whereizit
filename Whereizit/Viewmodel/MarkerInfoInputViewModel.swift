//
//  MarkerInfoInputViewModel.swift
//  Whereizit
//
//  Created by 이상지 on 12/12/25.
//

import Foundation
import RxRelay
import RxSwift
import RxCocoa

final class MarkerInfoInputViewModel {
  struct Input { // View -> ViewModel
    let saveData: Observable<AreaInput> // 구역 정보를 담은 데이터 스트림
  }
  
  struct Output { // ViewModel -> View
    //let dismiss: Observable<String> // 성공 여부 알림
  }

  init() {

  }

  func transform(input: Input) -> Output {
    .init()
  }

  struct AreaInput {
    let name: String?
    let description: String?
    let lat: Double?
    let lng: Double?
    let category: String?
    let finalImageURL: String?
  }


  private func saveAreaData(areaInput: AreaInput) {
    guard
      let name = areaInput.name,
      let description = areaInput.description,
      let lat = areaInput.lat,
      let lng = areaInput.lng,
      let category = areaInput.category,
      let finalImageURL = areaInput.finalImageURL
    else {
      return
    }
  }
}
