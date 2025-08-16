//
//  MarkerInfoInputViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/17/25.
//
import FirebaseCore
import FirebaseFirestore
import FlexLayout
import IQKeyboardManagerSwift
import NMapsMap
import Then

import UIKit

final class MarkerInfoInputViewController: UIViewController {
  
  var areaLat : Double?
  var areaLng: Double?
  
  // 1️⃣ 컬렉션뷰 선언
  private var collectionView: UICollectionView!
  
  // 2️⃣ 샘플 데이터
  private let items = ["아이템1", "아이템2", "아이템3"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.title = "컬렉션뷰 예제"
    
    // 3️⃣ 레이아웃 생성
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 12          // 셀 간 수직 간격
    layout.minimumInteritemSpacing = 8      // 셀 간 수평 간격
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // 자동 높이
    
    // 4️⃣ 컬렉션뷰 생성
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    
    // 5️⃣ 데이터소스 & 델리게이트 연결
    collectionView.dataSource = self
    collectionView.delegate = self
    
    // 6️⃣ 셀 등록
    collectionView.register(MyCell.self, forCellWithReuseIdentifier: "MyCell")
    
    // 7️⃣ 컬렉션뷰 추가 및 제약
    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}

// MARK: - UICollectionViewDataSource
extension MarkerInfoInputViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCell
    cell.configure(text: items[indexPath.item])
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MarkerInfoInputViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    // 너비는 컬렉션뷰 전체, 높이는 60으로 지정
    return CGSize(width: collectionView.bounds.width - 32, height: 60)
  }
}

// MARK: - 커스텀 셀
final class MyCell: UICollectionViewCell {
  
  private let label = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = .systemGray6
    contentView.layer.cornerRadius = 8
    
    contentView.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 16, weight: .medium)
    
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  func configure(text: String) {
    label.text = text
  }
}
