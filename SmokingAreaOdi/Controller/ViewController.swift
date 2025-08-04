//
//  ViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 7/14/25.
//

import NMapsMap
import SnapKit
import Then

import UIKit

// Unidirectional Data Flow (단방향 데이터 흐름)

// ViewController

// Rx

// 리액터kit input (action) / output (state)

// service

// Read 객체 / Wright 객체
// class 작성


final class ViewController: UIViewController { // 리네이밍

  // MARK: Constant

  private enum Metric {
    static let addButtonSize: CGFloat = 56
    static let addButtonTrailing: CGFloat = 24
    static let addButtonBottom: CGFloat = 40
  }


  // MARK: UI

  private let mapView = NMFMapView() // 현재 위치로 초기 로케이션 세팅
  private let addButton = UIButton().then {
    $0.tintColor = .white
    $0.backgroundColor = .systemGreen
    $0.layer.cornerRadius = Metric.addButtonSize / 2
    $0.clipsToBounds = true
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.3
    $0.layer.shadowOffset = CGSize(width: 0, height: 3)
    $0.layer.shadowRadius = 4
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Home"

    self.addSubviews()
    self.makeConstraints()

    self.configureAddButton()
  }


  private func addSubviews() {
    self.view.addSubview(self.mapView)
    self.view.addSubview(self.addButton)
  }

  private func makeConstraints() {
    self.mapView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    self.addButton.snp.makeConstraints{
      $0.size.equalTo(Metric.addButtonSize)
      $0.trailing.equalToSuperview().inset(Metric.addButtonTrailing)
      $0.bottom.equalToSuperview().inset(Metric.addButtonBottom)
    }
  }


  // MARK: Configure

  private func configureAddButton() {
    let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
    let plusImage = UIImage(systemName: "plus", withConfiguration: configuration)
    self.addButton.setImage(plusImage, for: .normal)

    self.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
  }

  @objc private func didTapAddButton() {
    let addVC = AddViewController()
    self.navigationController?.pushViewController(addVC, animated: true)
  }
}
