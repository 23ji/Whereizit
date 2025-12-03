//
//  MarkerInfoViewModel.swift
//  Whereizit
//
//  Created by 23ji on 12/4/25.
//

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
}
