import NMapsMap

class MarkerManager {
    private var markers: [NMFMarker] = []

    // MARK: - 마커 추가
    func addMarkers(for smokingAreas: [SmokingArea], to mapView: NMFMapView, viewController: ViewController) {
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
            marker.touchHandler = { [weak viewController] (overlay) in
                if overlay is NMFMarker, let viewController = viewController {
                    print("✅ 마커 터치 이벤트 발생: \(smokingArea.name)")
                    
                    // PopUp 정보 표시
                    viewController.showPopUpInfo(for: smokingArea)
                    
                    return true // 이벤트 소비 (false면 이벤트 전파)
                }
                return false
            }
            
            markers.append(marker)
        }
    }
}
