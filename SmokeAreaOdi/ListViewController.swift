//
//  ListViewController.swift
//  SmokeAreaOdi
//
//  Created by 이상지 on 1/16/25.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // 셀을 클래스 형식으로 등록
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SmokingAreaCell")
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()  // 데이터가 바뀌면 테이블 뷰 갱신
    }
}

extension ListViewController: UITableViewDataSource {

    // 테이블 뷰의 섹션 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1  // 섹션 개수는 1로 설정
    }

    // 섹션 내 행의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return smokingAreas.count  // smokingAreas 배열의 개수만큼 행 표시
    }

    // 셀을 생성하고 데이터 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SmokingAreaCell", for: indexPath)

        // 각 흡연구역 데이터 설정
        let area = smokingAreas[indexPath.row]
        cell.textLabel?.text = area.name
        cell.detailTextLabel?.text = "위도: \(area.latitude), 경도: \(area.longitude)"

        return cell
    }
}

extension ListViewController: UITableViewDelegate {

    // 셀 선택 시 동작 (예: 세부 정보 보기)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArea = smokingAreas[indexPath.row]
        print("Selected Area: \(selectedArea.name), \(selectedArea.latitude), \(selectedArea.longitude)")

        // 추가적으로 세부 화면으로 이동하거나 동작을 구현할 수 있음
    }
}
