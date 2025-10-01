//
//  NearbySmokingAreasBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 9/15/25.
//

import FirebaseFirestore
import FlexLayout
import PinLayout
import Then

import UIKit


final class NearbySmokingAreasBottomSheetViewController: UIViewController {
  
  private let rootContainer = UIView()
  
  private let titleLabel = UILabel().then {
    $0.text = "주변 흡연구역 목록"
    $0.font = .systemFont(ofSize: 15, weight: .regular)
    $0.textAlignment = .center
  }
  
  private let tableView = UITableView()
  
  private var smokingAreas: [String] = []
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    
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
    //데이터 가져오기
  }
}


extension NearbySmokingAreasBottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = "Row \(indexPath.row + 1)"
    return cell
  }
}
