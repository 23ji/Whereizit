// MarkerManager.swift

import NMapsMap

class MarkerManager {
    private var markers: [NMFMarker] = []

    init() {
        // NotificationCenter에서 새로운 흡연구역 추가 감지
        NotificationCenter.default.addObserver(self, selector: #selector(addMarkerFromNotification(_:)), name: .newSmokingAreaAdded, object: nil)
    }

    // MARK: - 마커 추가 메서드
    func addMarker(for smokingArea: SmokingArea, to mapView: NMFMapView) {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: smokingArea.latitude, lng: smokingArea.longitude)
        marker.captionText = smokingArea.name
        
        // 커스텀 마커 이미지 설정
        if let customImage = UIImage(named: "marker_Pin") {
            marker.iconImage = NMFOverlayImage(image: customImage)
        }
        
        marker.mapView = mapView
        
        // 마커 터치 이벤트 설정
        marker.touchHandler = { (overlay) in
            if overlay is NMFMarker {
                print("마커 터치 이벤트 발생: \(smokingArea.name)")
                return true // 이벤트 소비
            }
            return false
        }
        
        markers.append(marker)
    }

    // MARK: - NotificationCenter에서 마커 추가 요청 처리
    @objc private func addMarkerFromNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let smokingArea = userInfo["area"] as? SmokingArea else { return }
        
        // mapView를 Notification에서는 받을 수 없으므로, 이를 `ViewController`에서 직접 호출해야 함
        print("새로운 흡연구역 추가됨: \(smokingArea.name), 마커를 추가하려면 addMarker 호출 필요")
    }
}
