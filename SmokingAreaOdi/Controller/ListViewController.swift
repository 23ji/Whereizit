import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    private var smokingAreas: [SmokingArea] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        fetchSmokingAreas() // Firestore에서 데이터 가져오기
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSmokingAreas), name: .smokingAreaAdded, object: nil)
        
        // 셀 높이를 동적으로 설정
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .singleLine
    }

    // Firestore에서 데이터 가져오기
    private func fetchSmokingAreas() {
        FirestoreManager.shared.fetchSmokingAreas { [weak self] areas in
            guard let self = self else { return }
            self.smokingAreas = areas
            self.tableView.reloadData()
        }
    }

    @objc private func reloadSmokingAreas() {
        fetchSmokingAreas()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return smokingAreas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SmokingAreaCell", for: indexPath)
        let area = smokingAreas[indexPath.row]
        
        cell.textLabel?.text = area.name
        cell.detailTextLabel?.text = area.description.isEmpty ? " " : area.description
        
        return cell
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
