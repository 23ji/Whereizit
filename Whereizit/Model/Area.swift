//
//  Area.swift
//  Whereizit
//
//  Created by 이상지 on 8/29/25.
//

import FirebaseFirestore

import Foundation

struct Area: Codable {
  @DocumentID var documentID: String?
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
  
  enum CodingKeys: String, CodingKey {
    case documentID
    case imageURL
    case name
    case description
    case areaLat
    case areaLng
    case category
    case selectedEnvironmentTags = "environmentTags"
    case selectedTypeTags = "typeTags"
    case selectedFacilityTags = "facilityTags"
    case uploadUser
    case uploadDate
  }
}
