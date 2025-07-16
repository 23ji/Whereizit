//
//  ViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/14/25.
//
// SmokingAreaOdi/Controller/ViewController.swift

import UIKit

final class ViewController: UIViewController {
    
  private let mainView = MainView()
  
  override func loadView() {
    view = mainView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mainView.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    self.navigationItem.title = "Home"
  }
  
  @objc private func didTapAddButton() {
    print("버튼 눌림")
    let addVC = AddViewController()
    navigationController?.pushViewController(addVC, animated: true)
  }
}
