//
//  NearbySmokingAreasBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 9/15/25.
//

import FirebaseAuth
import FirebaseFirestore
import FlexLayout
import PinLayout
import Then

import UIKit


final class NearbySmokingAreasBottomSheetViewController: UIViewController {
  
  let user = Auth.auth().currentUser
  
  private let rootContainer = UIView()
  
  private let titleLabel = UILabel().then {
    $0.text = "주변 흡연구역 목록"
    $0.font = .systemFont(ofSize: 15, weight: .regular)
    $0.textAlignment = .center
  }
  
  private let tableView = UITableView()
  
  let db = Firestore.firestore()
  
  private var smokingAreas: [SmokingArea] = []
  
  private var areaName: String = ""
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.fetchSmokingAreas()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    self.tableView.register(SmokingAreaTableViewCell.self, forCellReuseIdentifier: "SmokingAreaCell")
    self.tableView.rowHeight = UITableView.automaticDimension
    self.tableView.estimatedRowHeight = 120
    
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
  
  private func fetchSmokingAreas() {
    db.collection("smokingAreas").addSnapshotListener { [weak self] snapshot, error in
      guard let self = self, let snapshot = snapshot else { return }
      
      var newAreas: [SmokingArea] = []
      
      for doc in snapshot.documents {
        let data = doc.data()
        
        if let name = data["name"] as? String,
           let description = data["description"] as? String,
           let areaLat = data["areaLat"] as? Double,
           let areaLng = data["areaLng"] as? Double {
          
          let imageURL = data["imageURL"] as? String
          let envTags = data["environmentTags"] as? [String] ?? []
          let typeTags = data["typeTags"] as? [String] ?? []
          let facTags = data["facilityTags"] as? [String] ?? []
          let timestamp = data["uploadDate"] as? Timestamp ?? Timestamp(date: Date())

          let area = SmokingArea(
              imageURL: imageURL,
              name: name,
              description: description,
              areaLat: areaLat,
              areaLng: areaLng,
              selectedEnvironmentTags: envTags,
              selectedTypeTags: typeTags,
              selectedFacilityTags: facTags,
              uploadUser: self.user?.email ?? "",
              uploadDate: timestamp
          )

          newAreas.append(area)
        }
      }
      
      self.smokingAreas = newAreas
      self.tableView.reloadData()
    }
  }
}


extension NearbySmokingAreasBottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return smokingAreas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SmokingAreaCell", for: indexPath)
            as? SmokingAreaTableViewCell else { return UITableViewCell() }
    
    let area = smokingAreas[indexPath.row]
    
    // area 데이터 cell의 configure에 넘겨주기
    cell.configure(with: area)
    
    return cell
  }
}
