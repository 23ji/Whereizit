//
//  Area.swift
//  Whereizit
//
//  Created by 이상지 on 8/29/25.
//

import FirebaseFirestore

import Foundation

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
      Constant.Firestore.Field.documentID : documentID,
      Constant.Firestore.Field.imageURL: imageURL,
      Constant.Firestore.Field.name: name,
      Constant.Firestore.Field.description: description,
      Constant.Firestore.Field.areaLat: areaLat,
      Constant.Firestore.Field.areaLng: areaLng,
      Constant.Firestore.Field.category: category,
      Constant.Firestore.Field.environmentTags: selectedEnvironmentTags,
      Constant.Firestore.Field.typeTags: selectedTypeTags,
      Constant.Firestore.Field.facilityTags: selectedFacilityTags,
      Constant.Firestore.Field.uploadUser: uploadUser,
      Constant.Firestore.Field.uploadDate: uploadDate
      ]
    }
}
