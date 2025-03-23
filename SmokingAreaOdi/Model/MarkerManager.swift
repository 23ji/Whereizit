import NMapsMap

class MarkerManager {
    private var markers: [NMFMarker] = []
    
    func addMarkers(for smokingAreas: [SmokingArea], to mapView: NMFMapView, viewController: ViewController) {
        // ✅ 기존 마커 삭제
        for marker in markers {
            marker.mapView = nil
        }
        markers.removeAll()
        
        for smokingArea in smokingAreas { //forEach
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: smokingArea.latitude, lng: smokingArea.longitude)
            marker.captionText = smokingArea.name
            
            if let customImage = UIImage(named: "marker_Pin") { //Constants
                marker.iconImage = NMFOverlayImage(image: customImage)
            }
            
            marker.mapView = mapView
            
            marker.touchHandler = { [weak viewController] (overlay) in
                if overlay is NMFMarker, let viewController = viewController {
                    print("✅ 마커 터치 이벤트 발생: \(smokingArea.name)")
                    viewController.showPopUpInfo(for: smokingArea)
                    return true
                }
                return false
            }
            
            markers.append(marker)
        }
    }
}
