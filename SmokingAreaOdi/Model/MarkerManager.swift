import NMapsMap

class MarkerManager {
    private var markers: [NMFMarker] = []

    // MARK: - 마커 추가
    func addMarkers(for smokingAreas: [SmokingArea], to mapView: NMFMapView) {
        for smokingArea in smokingAreas {
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
                    print("✅ 마커 터치 이벤트 발생: \(smokingArea.name)")
                    return true // 이벤트 소비 (false면 이벤트 전파)
                }
                return false
            }
            
            markers.append(marker)
        }
    }
}
