//
//  AreaRepository.swift
//  Whereizit
//
//  Created by 23ji on 11/26/25.
//

import RxSwift
import FirebaseFirestore
import FirebaseStorage

final class AreaRepository {
  static let shared = AreaRepository()
  private let db = Firestore.firestore()

  private let collectionPath = "smokingAreas"

  func addArea(area: Area) -> Observable<Void> {
    return Observable.create { [weak self] observer in
      guard let self = self, let documentID = area.documentID else {
        observer.onError(NSError(domain: "InvalidData", code: 400, userInfo: nil))
        return Disposables.create()
      }

      self.db.collection(self.collectionPath).document(documentID).setData(area.asDictionary) { error in
        if let error = error {
          observer.onError(error)
        } else {
          observer.onNext(())
          observer.onCompleted()
        }
      }
      return Disposables.create()
    }
  }
}
