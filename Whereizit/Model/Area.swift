//
//  Area.swift
//  Whereizit
//
//  Created by 이상지 on 8/29/25.
//

import FirebaseFirestore

import Foundation
// 🛠️ Firebase Firestore 문서 구조와 매핑되는 Area 구조체를 정의
struct Area {
  var documentID: String?
  var imageURL: String?
  var name: String
  var description: String
  var areaLat: Double
  var areaLng: Double
  var category: String
  var selectedEnvironmentTags: [String]
  var selectedTypeTags: [String]
  var selectedFacilityTags: [String]
  var uploadUser: String
  var uploadDate: Timestamp
  
  var asDictionary: [String: Any] {
      return [
        "documentID" : documentID,
        "imageURL": imageURL,
        "name": name,
        "description": description,
        "areaLat": areaLat,
        "areaLng": areaLng,
        "category": category,
        "environmentTags": selectedEnvironmentTags,
        "typeTags": selectedTypeTags,
        "facilityTags": selectedFacilityTags,
        "uploadUser": uploadUser,
        "uploadDate": uploadDate
      ]
    }
}
