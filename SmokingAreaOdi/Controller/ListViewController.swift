import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    private var smokingAreas: [SmokingArea] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    
        loadSmokingAreas()

        NotificationCenter.default.addObserver(self, selector: #selector(smokingAreaAdded(_:)), name: .smokingAreaAdded, object: nil)
        
        // 셀 높이를 동적으로 설정
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100 // 예상 셀 높이 설정
        tableView.separatorStyle = .singleLine
    }

    private func loadSmokingAreas() {
        smokingAreas = SmokingAreaData.shared.smokingAreas
        tableView.reloadData()
    }

    @objc private func smokingAreaAdded(_ notification: Notification) {
        if let newArea = notification.userInfo?["area"] as? SmokingArea {
            smokingAreas.append(newArea)
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return smokingAreas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SmokingAreaCell", for: indexPath)
        let area = smokingAreas[indexPath.row]
        
        cell.textLabel?.text = area.name
        if area.description == nil || area.description.isEmpty == true {
            cell.detailTextLabel?.text = " " // 텍스트가 없으면 공백을 넣어주면 셀 높이가 비슷해짐
        } else {
            cell.detailTextLabel?.text = area.description
        }
        
        return cell
    }
    
    // 셀 높이 조정 (셀 간격을 띄우기 위한 방법)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // 각 셀의 고정 높이를 설정하거나 dynamic으로 설정 가능
    }

    // 셀 간의 간격을 띄우기 위한 방법
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            cell.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0) // 셀 하단에 10pt 간격 추가
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
