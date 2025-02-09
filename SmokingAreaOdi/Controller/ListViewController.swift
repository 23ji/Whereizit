import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    private var smokingAreas: [SmokingArea] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        // 셀 등록 (스토리보드에서 셀 설정이 안 되었을 경우 대비)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SmokingAreaCell")

        loadSmokingAreas()

        NotificationCenter.default.addObserver(self, selector: #selector(smokingAreaAdded(_:)), name: .smokingAreaAdded, object: nil)
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
        cell.detailTextLabel?.text = area.description
        return cell
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
