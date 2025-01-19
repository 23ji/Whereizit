// SmokingAreaData.swift

import Foundation

struct SmokingArea: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    let description: String  // 상세 설명 추가
}

//// 흡연구역 기본 데이터
//var smokingAreas: [SmokingArea] = [
//   
//]

// UserDefaults 키
private let smokingAreaKey = "smokingAreaData"

// 흡연구역 데이터 가져오기
var smokingAreas: [SmokingArea] {
    get {
        // UserDefaults에서 데이터 불러오기
        if let savedData = UserDefaults.standard.data(forKey: smokingAreaKey),
           let decodedData = try? JSONDecoder().decode([SmokingArea].self, from: savedData) {
            return decodedData
        }
        return []
    }
    set {
        // 데이터를 UserDefaults에 저장
        if let encodedData = try? JSONEncoder().encode(newValue) {
            UserDefaults.standard.set(encodedData, forKey: smokingAreaKey)
        }
    }
}

