// SmokingAreaData.swift

import Foundation

struct SmokingArea: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    let description: String
}

class SmokingAreaData {
    static let shared = SmokingAreaData()

    private let storageKey = "smokingAreas"
    private init() {}

    var smokingAreas: [SmokingArea] {
        get {
            guard let data = UserDefaults.standard.data(forKey: storageKey),
                  let areas = try? JSONDecoder().decode([SmokingArea].self, from: data) else {
                return []
            }
            return areas
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: storageKey)
            }
        }
    }

    func addSmokingArea(_ area: SmokingArea) {
        var currentAreas = smokingAreas
        currentAreas.append(area)
        smokingAreas = currentAreas
    }
}
