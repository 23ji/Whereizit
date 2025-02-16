import Foundation
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()

    private init() {}

    // MARK: - Firestore 데이터 가져오기
    func fetchSmokingAreas(completion: @escaping ([SmokingArea]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("smokingAreas").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Firestore 데이터 가져오기 실패: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("⚠️ 가져온 데이터가 비어 있음")
                completion([])
                return
            }
            
            var smokingAreas: [SmokingArea] = []
            
            for document in documents {
                let data = document.data()
                guard
                    let name = data["name"] as? String,
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double,
                    let description = data["description"] as? String
                else {
                    print("❌ 데이터 파싱 실패: \(data)")
                    continue
                }
                
                let smokingArea = SmokingArea(
                    name: name,
                    latitude: latitude,
                    longitude: longitude,
                    description: description
                )
                
                smokingAreas.append(smokingArea)
            }
            
            completion(smokingAreas)
        }
    }
}
