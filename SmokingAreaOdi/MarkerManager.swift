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
            currentMarker = NMFMarker()
            currentMarker?.position = center
            currentMarker?.mapView = mapView
            currentMarker?.captionText = "새로운 마커"
        } else {
            currentMarker?.position = center
        }
    }
    
    func removeMarker() {
        currentMarker?.mapView = nil
        currentMarker = nil
    }
}
