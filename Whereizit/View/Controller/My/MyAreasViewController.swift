//
//  MyAreasViewController.swift
//  Whereizit
//
//  Created by 이상지 on 10/20/25.
//

import FirebaseAuth
import FirebaseFirestore
import FlexLayout
import PinLayout
import Then

import CoreLocation
import UIKit

final class MyAreasViewController: UIViewController {
  
  let user = Auth.auth().currentUser
  
  private let rootContainer = UIView()
  
  private let locationManager = CLLocationManager()
  private var currentLocation: CLLocation?
  
  private let titleLabel = UILabel().then {
    $0.text = "주변 목록"
    $0.font = .systemFont(ofSize: 15, weight: .regular)
    $0.textAlignment = .center
  }
  
  private let tableView = UITableView().then {
    $0.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
  }
  
  let db = Firestore.firestore()
  
  private var areas: [Area] = []
  
  private var areaName: String = ""
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "내가 추가한 구역 목록"
    self.view.backgroundColor = .white
    self.fetchAreas()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    self.tableView.register(AreaTableViewCell.self, forCellReuseIdentifier: "AreaCell")
    self.tableView.rowHeight = UITableView.automaticDimension
    self.tableView.estimatedRowHeight = 120
    
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
    
    self.view.addSubview(rootContainer)
    self.setupLayout()
  }
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.rootContainer.pin.all()
    self.rootContainer.flex.layout()
  }
  
  
  private func setupLayout() {
    self.rootContainer.flex.justifyContent(.start).marginTop(30)
      .alignItems(.center)
      .define {
        $0.addItem(self.titleLabel)
        $0.addItem(self.tableView).height(100%).marginTop(15)
      }
  }
  
  private func fetchAreas() {
    guard let userEmail = self.user?.email else { return }
    // 🛠️ Firebase에서 데이터 불러오기
    db.collection("smokingAreas")
      .whereField("uploadUser", isEqualTo: userEmail)
      .addSnapshotListener { [weak self] snapshot, error in
        guard let self = self, let snapshot = snapshot else { return }
        
        var newAreas: [Area] = []
        
        for doc in snapshot.documents {
          let data = doc.data()
          
          if let name = data["name"] as? String,
             let description = data["description"] as? String,
             let areaLat = data["areaLat"] as? Double,
             let areaLng = data["areaLng"] as? Double,
             let category = data["category"] as? String {

            let imageURL = data["imageURL"] as? String
            let envTags = data["environmentTags"] as? [String] ?? []
            let typeTags = data["typeTags"] as? [String] ?? []
            let facTags = data["facilityTags"] as? [String] ?? []
            let timestamp = data["uploadDate"] as? Timestamp ?? Timestamp(date: Date())
            
            let area = Area(
              documentID: doc.documentID,
              imageURL: imageURL,
              name: name,
              description: description,
              areaLat: areaLat,
              areaLng: areaLng,
              category: category,
              selectedEnvironmentTags: envTags,
              selectedTypeTags: typeTags,
              selectedFacilityTags: facTags,
              uploadUser: self.user?.email ?? "",
              uploadDate: timestamp
            )
            
            newAreas.append(area)
          }
        }
        // 🛠️ 거리순으로 정렬
        // 현재 위치가 있으면 거리 기준으로 정렬
        if let currentLocation = self.currentLocation {
          newAreas.sort { a, b in
            let locA = CLLocation(latitude: a.areaLat, longitude: a.areaLng)
            let locB = CLLocation(latitude: b.areaLat, longitude: b.areaLng)
            return currentLocation.distance(from: locA) < currentLocation.distance(from: locB)
          }
        }
        
        self.areas = newAreas
        self.tableView.reloadData()
      }
  }
}


extension MyAreasViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return areas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "AreaCell", for: indexPath)
            as? AreaTableViewCell else { return UITableViewCell() }
    
    let area = areas[indexPath.row]

    // area 데이터 cell의 configure에 넘겨주기
    cell.configure(with: area, currentLocation: currentLocation)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let area = areas[indexPath.row]

    // BottomSheet 띄우기
    let bottomSheetVC = AreaBottomSheetViewController()
    bottomSheetVC.configure(with: area)
    bottomSheetVC.modalPresentationStyle = .pageSheet
    
    if let sheet = bottomSheetVC.sheetPresentationController {
      sheet.detents = [.medium(), .large()] // 높이 조절
      sheet.prefersGrabberVisible = true // 위에 손잡이 표시
      sheet.preferredCornerRadius = 20
    }
    
    present(bottomSheetVC, animated: true)
  }
}


extension MyAreasViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.currentLocation = locations.last
    
    // 거리 기준 정렬
    if let currentLocation = self.currentLocation {
      self.areas.sort { a, b in
        let locA = CLLocation(latitude: a.areaLat, longitude: a.areaLng)
        let locB = CLLocation(latitude: b.areaLat, longitude: b.areaLng)
        return currentLocation.distance(from: locA) < currentLocation.distance(from: locB)
      }
    }
    
    self.tableView.reloadData() // 위치 업데이트되면 거리 표시 갱신
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location error: \(error.localizedDescription)")
  }
}

