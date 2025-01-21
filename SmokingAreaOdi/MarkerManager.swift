import NMapsMap

class MarkerManager {
    // MARK: - Properties
    private weak var mapView: NMFMapView?  // 맵뷰 참조
    private var currentMarker: NMFMarker?
    
    // MARK: - Initializer
    init(mapView: NMFMapView) {
        self.mapView = mapView
    }
    
    // MARK: - Methods
    func addMarker(at center: NMGLatLng) {
        if currentMarker == nil {
            // 새 마커 생성
            currentMarker = NMFMarker()
            currentMarker?.position = center
            currentMarker?.mapView = mapView
            currentMarker?.captionText = "새로운 마커"
        } else {
            // 기존 마커 위치 업데이트
            currentMarker?.position = center
        }
    }
    
    func removeMarker() {
        // 마커 제거
        currentMarker?.mapView = nil
        currentMarker = nil
    }
}

