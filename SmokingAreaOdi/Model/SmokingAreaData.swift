import Foundation

class SmokingAreaData {
    static let shared = SmokingAreaData()
    private(set) var smokingAreas: [SmokingArea] = []
    
    private init() {}
    
    func addSmokingArea(_ area: SmokingArea) {
        smokingAreas.append(area)
    }
}
