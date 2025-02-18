import UIKit
import NMapsMap

class MarkerManager {
    private var markers: [NMFMarker] = []

    // MARK: - 마커 추가
    func addMarkers(for smokingAreas: [SmokingArea], to mapView: NMFMapView, viewController: UIViewController) {
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
                if overlay is NMFMarker {
                    print("✅ 마커 터치 이벤트 발생: \(smokingArea.name)")
                    
                    // PopUpViewController에서 알림창 띄우기
                    if let viewController = viewController, viewController.view.window != nil {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "흡연 구역", message: "\(smokingArea.name)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                            viewController.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        print("⚠️ 알림창을 띄울 수 없음: ViewController가 화면에 표시되지 않음")
                    }
                    
                    return true // 이벤트 소비 (false면 이벤트 전파)
                }
                return false
            }
            
            markers.append(marker)
        }
    }
}
