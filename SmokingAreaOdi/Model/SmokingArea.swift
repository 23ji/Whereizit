//
//  SmokingArea.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 8/29/25.
//

import Foundation

struct SmokingArea {
  // var picture: Image
  var name: String
  var description: String
  var areaLat: Double
  var areaLng: Double
  var selectedEnvironmentTags: [String]
  var selectedTypeTags: [String]
  var selectedFacilityTags: [String]
  // var uploadUser: String
  // var uploadDate
  
  var asDictionary: [String: Any] {
      return [
        "name": name,
        "description": description,
        "areaLat": areaLat,
        "areaLng": areaLng,
        "environmentTags": selectedEnvironmentTags,
        "typeTags": selectedTypeTags,
        "facilityTags": selectedFacilityTags
      ]
    }
}
