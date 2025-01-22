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
                
                // 중복 추가 방지 (이미 추가된 데이터는 스킵)
                if SmokingAreaData.shared.smokingAreas.contains(where: { $0.name == name && $0.latitude == latitude && $0.longitude == longitude }) {
                    continue
                }
                
                let smokingArea = SmokingArea(
                    name: name,
                    latitude: latitude,
                    longitude: longitude,
                    description: description
                )
                
                // SmokingAreaData에 추가
                SmokingAreaData.shared.addSmokingArea(smokingArea)
                
                // 지도에 마커 추가
                let marker = NMFMarker()
                marker.position = NMGLatLng(lat: latitude, lng: longitude)
                marker.captionText = name
                
                // 커스텀 마커 이미지 설정
                if let customImage = UIImage(named: "marker_Pin") {
                    marker.iconImage = NMFOverlayImage(image: customImage)
                }
                
                marker.mapView = self.naverMapView.mapView
            }
        }
    }

    // MARK: - Notification 처리
    @objc func smokingAreaAdded(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let newArea = userInfo["area"] as? SmokingArea else { return }

        // SmokingAreaData에 추가
        SmokingAreaData.shared.addSmokingArea(newArea)

        // 마커 추가
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: newArea.latitude, lng: newArea.longitude)
        marker.captionText = newArea.name
        
        // 커스텀 마커 이미지 설정
        if let customImage = UIImage(named: "marker_Pin") {
            marker.iconImage = NMFOverlayImage(image: customImage)
            
        }

        marker.mapView = naverMapView.mapView
    }
}
