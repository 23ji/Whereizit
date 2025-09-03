//
//  SmokingAreaBottomSheetViewController.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 8/31/25.
//

import UIKit

final class SmokingAreaBottomSheetViewController: UIViewController {
  
  // MARK:  Properties
  
  private var areaData: SmokingArea?
  
  
  // MARK:  UI
  
  let tableView = UITableView(frame: .zero, style: .insetGrouped).then {
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    $0.separatorStyle = .none
    $0.backgroundColor = .white
  }
  
  let collectionView = UICollectionView().then {
    $0.backgroundColor = .purple
  }
  
  
  // MARK:  LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.view.addSubview(tableView)
    self.view.addSubview(collectionView)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.tableView.frame = view.bounds
  }
  
  
  // MARK:  Configure
  
  func configure(with area: SmokingArea) {
    self.areaData = area
    DispatchQueue.main.async { [weak self] in
      self?.tableView.reloadData()
    }
  }
}
