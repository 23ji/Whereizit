import UIKit

class PopUpViewController {
    // 하단에 떠 있을 뷰 추가
    var infoView: UIView!
    var infoLabel: UILabel!
    var closeButton: UIButton!
    var parentView: UIView!

    init(parentView: UIView) {
        self.parentView = parentView
        setupInfoView() // 정보 뷰 초기화
    }
    
    private func setupInfoView() {
        // 하단 정보 뷰 설정
        infoView = UIView()
        infoView.backgroundColor = .white
        infoView.layer.cornerRadius = 10
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOpacity = 0.3
        infoView.layer.shadowRadius = 5
        infoView.layer.shadowOffset = CGSize(width: 0, height: -2)
        infoView.frame = CGRect(x: 20, y: self.parentView.frame.height, width: self.parentView.frame.width - 40, height: 150)
        self.parentView.addSubview(infoView)

        // 정보 레이블 설정
        infoLabel = UILabel()
        infoLabel.frame = CGRect(x: 20, y: 20, width: infoView.frame.width - 40, height: 100)
        infoLabel.numberOfLines = 0
        infoLabel.textColor = .black
        infoLabel.font = UIFont.systemFont(ofSize: 16)
        infoView.addSubview(infoLabel)
        
        // 닫기 버튼 설정
        closeButton = UIButton(type: .system)
        closeButton.frame = CGRect(x: infoView.frame.width - 60, y: 10, width: 50, height: 30)
        closeButton.setTitle("닫기", for: .normal)
        closeButton.addTarget(self, action: #selector(closeInfoView), for: .touchUpInside)
        infoView.addSubview(closeButton)
    }

    func showInfo(for smokingArea: SmokingArea) {
        infoLabel.text = "구역 이름: \(smokingArea.name)\n기타 정보: \(smokingArea.description)"
        
        // 애니메이션으로 하단에서 슬라이드 업
        UIView.animate(withDuration: 0.3) {
            self.infoView.frame.origin.y = self.parentView.frame.height - self.infoView.frame.height - 20
        }
    }

    // MARK: - 닫기 버튼 액션
    @objc func closeInfoView() {
        // 애니메이션으로 하단으로 슬라이드 다운
        UIView.animate(withDuration: 0.3) {
            self.infoView.frame.origin.y = self.parentView.frame.height
        }
    }
}
