import UIKit

class PopUpView {
    var infoView: UIView!
    var infoLabel: UILabel!
    var closeButton: UIButton!
    var parentView: UIView!
    
    init(parentView: UIView) {
        self.parentView = parentView
        setupInfoView()
    }
    
    private func setupInfoView() {
        // ✅ 팝업 뷰 설정
        infoView = UIView()
        infoView.backgroundColor = .white
        infoView.layer.cornerRadius = 20
        infoView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner] // 모든 모서리 둥글게
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOpacity = 0.2
        infoView.layer.shadowRadius = 10
        infoView.layer.shadowOffset = CGSize(width: 0, height: -5) // 그림자 효과로 떠 보이게

        infoView.frame = CGRect(x: 20, y: parentView.frame.height, width: parentView.frame.width - 40, height: 180)
        parentView.addSubview(infoView)

        // ✅ 정보 레이블 설정
        infoLabel = UILabel()
        infoLabel.frame = CGRect(x: 20, y: 40, width: infoView.frame.width - 40, height: 80)
        infoLabel.numberOfLines = 0
        infoLabel.textColor = .black
        infoLabel.font = UIFont.systemFont(ofSize: 16)
        infoLabel.textAlignment = .left
        infoView.addSubview(infoLabel)
        
        // ✅ 닫기 버튼 설정
        closeButton = UIButton(type: .system)
        closeButton.frame = CGRect(x: infoView.frame.width - 60, y: 10, width: 50, height: 30)
        closeButton.setTitle("닫기", for: .normal)
        closeButton.addTarget(self, action: #selector(closeInfoView), for: .touchUpInside)
        infoView.addSubview(closeButton)
    }

    func showInfo(for smokingArea: SmokingArea) {
        infoLabel.text = "🚬 구역 이름: \(smokingArea.name)\n📍 위치 정보: \(smokingArea.description)"
        infoLabel.textAlignment = .left
        
        // ✅ 애니메이션으로 슬라이드 업
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.infoView.frame.origin.y = self.parentView.frame.height - self.infoView.frame.height - 100
        }
    }

    // ✅ 닫기 버튼 액션
    @objc func closeInfoView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.infoView.frame.origin.y = self.parentView.frame.height
        }
    }
}
