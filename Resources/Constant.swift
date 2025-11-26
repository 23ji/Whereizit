//
//  Constant.swift
//  Whereizit
//
//  Created by 23ji on 11/9/25.
//

import Foundation

enum Constant {
  static let defaultImage: String = "defaultImage"

  enum Firestore {
    // 컬렉션 이름
    enum Collection {
      static let smokingAreas = "smokingAreas"
      static let reports = "reports"
    }

    // 필드 이름 (Key값)
    enum Field {
      static let name = "name"
      static let description = "description"
      static let areaLat = "areaLat"
      static let areaLng = "areaLng"
      static let imageURL = "imageURL"
      static let category = "category"
      static let environmentTags = "environmentTags"
      static let typeTags = "typeTags"
      static let facilityTags = "facilityTags"
      static let uploadUser = "uploadUser"
      static let uploadDate = "uploadDate"
      static let documentID = "documentID"
    }

    enum ReportField {
      static let reportedAreaID = "reportedAreaID"
      static let reportedName = "reportedName"
      static let reportedBy = "reportedBy"
      static let reason = "reason"
      static let timestamp = "timestamp"
    }
  }

  // Firebase Storage 관련 상수
  enum Storage {
    static let folderName = "smokingAreas"
  }

  // 카테고리 및 태그
  enum AppData {
    static let categories = ["화장실", "쓰레기통", "물", "흡연구역"]

    static let categoryTagsMap: [String: [String: [String]]] = [
      "화장실": [
        "환경": ["남녀 구분", "남녀 공용"],
        "유형": ["건물", "식당", "술집", "카페"],
        "시설": ["휴지", "비데"]
      ],
      "쓰레기통": [
        "환경": ["일반 쓰레기", "재활용 쓰레기"],
        "유형": ["실외", "실내"],
        "시설": ["분리수거"]
      ],
      "물": [
        "환경": ["실내", "실외"],
        "유형": ["정수기", "음수대", "약수터"],
        "시설": ["온수", "얼음"]
      ],
      "흡연구역": [
        "환경": ["실내", "실외", "밀폐형", "개방형"],
        "유형": ["흡연 구역", "카페", "술집", "식당", "노래방", "보드게임 카페", "당구장", "피시방"],
        "시설": ["별도 전자담배 구역", "의자", "라이터"]
      ]
    ]
  }
}
