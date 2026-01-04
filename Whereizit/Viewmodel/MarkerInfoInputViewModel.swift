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
    let dismiss: Observable<String>
  }

  init() {

  }

//  func transform(input: Input) -> Output {
//    
//  }

  struct AreaInput {
    let name: String?
    let description: String?
    let lat: Double?
    let lng: Double?
    let category: String?
  }
}
