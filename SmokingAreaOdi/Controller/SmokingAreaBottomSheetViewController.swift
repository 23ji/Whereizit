//
//  SmokingAreaBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 8/31/25.
//

import UIKit

final class SmokingAreaBottomSheetViewController: UIViewController {
  
  // MARK: - Properties
  private var areaData: SmokingArea?
  
  // MARK: - UI
  let tableView = UITableView(frame: .zero, style: .insetGrouped).then {
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    $0.separatorStyle = .none
    $0.backgroundColor = .white
  }
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    view.addSubview(tableView)
    
    // ✅ dataSource, delegate 연결
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
  
  // MARK: - Configure
  func configure(with area: SmokingArea) {
    self.areaData = area
    DispatchQueue.main.async { [weak self] in
      self?.tableView.reloadData()
    }
  }
}

// MARK: - UITableViewDataSource
extension SmokingAreaBottomSheetViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3 // 이름, 설명, 태그
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let areaData else { return 0 }
    print(areaData.selectedEnvironmentTags)
    print(areaData.selectedTypeTags)
    print(areaData.selectedFacilityTags)

    switch section {
    case 0: return 1
    case 1: return 1
    case 2:
      return (areaData.selectedEnvironmentTags.count
            + areaData.selectedTypeTags.count
            + areaData.selectedFacilityTags.count)
    default: return 0
    }
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.selectionStyle = .none
    
    guard let areaData else { return cell }
    
    switch indexPath.section {
    case 0:
      cell.textLabel?.text = areaData.name
      cell.textLabel?.font = .boldSystemFont(ofSize: 18)
    case 1:
      cell.textLabel?.text = areaData.description
      cell.textLabel?.font = .systemFont(ofSize: 14)
      cell.textLabel?.textColor = .darkGray
    case 2:
      let tags = areaData.selectedEnvironmentTags
               + areaData.selectedTypeTags
               + areaData.selectedFacilityTags
      cell.textLabel?.text = tags[indexPath.row]
      cell.textLabel?.font = .systemFont(ofSize: 13)
      cell.textLabel?.textColor = .gray
    default:
      break
    }
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension SmokingAreaBottomSheetViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return "이름"
    case 1: return "설명"
    case 2: return "태그"
    default: return nil
    }
  }
}
