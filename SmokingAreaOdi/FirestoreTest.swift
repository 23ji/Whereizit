//
//  FirestoreTest.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 1/22/25.
//

// FirestoreTest.swift
// SmokeAreaOdi 프로젝트 내부의 테스트용 파일
import Foundation
import FirebaseFirestore

class FirestoreTest {
    
    private let db = Firestore.firestore()
    
    // Firestore에 데이터 추가
    func addTestData() {
        let testData: [String: Any] = [
            "name": "테스트 흡연구역",
            "latitude": 37.5665,
            "longitude": 126.9780,
            "description": "서울 광화문 흡연구역"
        ]
        
        db.collection("smokingAreas").addDocument(data: testData) { error in
            if let error = error {
                print("데이터 추가 실패: \(error.localizedDescription)")
            } else {
                print("데이터 추가 성공")
            }
        }
    }
    
    // Firestore에서 데이터 읽기
    func fetchTestData() {
        db.collection("smokingAreas").getDocuments { snapshot, error in
            if let error = error {
                print("데이터 읽기 실패: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("문서 없음")
                return
            }
            
            for document in documents {
                print("문서 ID: \(document.documentID), 데이터: \(document.data())")
            }
        }
    }
}

