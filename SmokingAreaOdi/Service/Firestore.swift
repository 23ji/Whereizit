// Firestore.swift

import Foundation
import FirebaseFirestore
import NMapsMap

extension ViewController {
    // MARK: - Firestore 데이터 가져오기
    func fetchSmokingAreasFromFirestore() {
        let db = Firestore.firestore()
        
        db.collection("smokingAreas").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Firestore 데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("가져온 데이터가 비어 있음")
                return
            }
            
            for document in documents {
                let data = document.data()
                guard
                    let name = data["name"] as? String,
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double,
                    let description = data["description"] as? String
                else {
                    print("데이터 파싱 실패: \(data)")
                    continue
                }
                
                let smokingArea = SmokingArea(
                    name: name,
                    latitude: latitude,
                    longitude: longitude,
                    description: description
                )
                
                // 중복 추가 방지
                if SmokingAreaData.shared.smokingAreas.contains(where: { $0.name == name && $0.latitude == latitude && $0.longitude == longitude }) {
                    continue
                }
                
                // SmokingAreaData에 추가
                SmokingAreaData.shared.addSmokingArea(smokingArea)
                
                // Notification을 사용해 MarkerManager에 마커 추가 요청
                NotificationCenter.default.post(name: .newSmokingAreaAdded, object: nil, userInfo: ["area": smokingArea])
            }
        }
    }
}

// MARK: - Notification Name 정의
extension Notification.Name {
    static let newSmokingAreaAdded = Notification.Name("newSmokingAreaAdded")
}
