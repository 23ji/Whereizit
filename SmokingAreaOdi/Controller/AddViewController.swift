//
//  AddViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/16/25.
//

import UIKit

class AddViewController: UIViewController {
  
  private let addView = AddView()
  
  override func loadView() {
    view = addView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "흡연구역 추가"
    // Do any additional setup after loading the view.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
