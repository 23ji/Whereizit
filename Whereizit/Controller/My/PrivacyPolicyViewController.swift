//
//  PrivacyPolicyViewController.swift
//  Whereizit
//
//  Created by 이상지 on 10/28/25.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class PrivacyPolicyViewController: UIViewController {
    
    private let rootContainer = UIView()
    private let titleLabel = UILabel().then {
        $0.text = "개인정보 처리방침"
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private let policyTextView = UITextView().then {
        $0.text = """
        개인정보 처리방침

        1. 개인정보의 수집 항목
           - 필수 수집 정보: 이메일, 닉네임, 프로필 사진
           - 선택 수집 정보: 위치 정보 (앱 내 기능 사용 시)
           - 수집 방법: 앱 회원가입, 앱 이용 과정에서 자동 수집

        2. 개인정보의 수집 및 이용 목적
           - 회원 관리 및 서비스 제공
           - 프로필 설정 및 맞춤형 서비스 제공
           - 고객 문의 및 지원 대응
           - 서비스 개선 및 통계 분석

        3. 개인정보의 보유 및 이용 기간
           - 회원 탈퇴 시까지 보유
           - 법령에 따른 보관 의무가 있는 경우 해당 기간 동안 보관

        4. 개인정보의 제3자 제공
           - 수집한 개인정보는 원칙적으로 제3자에게 제공하지 않음
           - 단, 법령에 의한 요구가 있는 경우 예외적으로 제공 가능

        5. 개인정보 처리 위탁
           - 이미지 저장: Firebase Storage
           - 로그인 인증: Firebase Auth
           - 위탁 범위: 위탁 서비스 제공 목적에 한정

        6. 이용자의 권리 및 행사 방법
           - 개인정보 열람, 정정, 삭제 요청 가능
           - 개인정보 처리 정지 요청 가능
           - 요청 방법: 앱 내 문의 또는 이메일(23g1014@gmail.com)

        7. 개인정보의 안전성 확보 조치
           - SSL 암호화 통신 적용
           - 서버 접근 권한 제한
           - 정기적인 보안 점검 시행

        8. 개인정보 처리방침 변경
           - 정책 변경 시 앱 공지 또는 업데이트를 통해 안내
           - 최종 업데이트 일자 명시

        9. 연락처
           - 개인정보 보호책임자: 이상지
           - 연락처: 23g1014@gmail.com

        """
        $0.font = .systemFont(ofSize: 16)
        $0.isEditable = false
        $0.isScrollEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(rootContainer)
        layout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootContainer.pin.all(view.pin.safeArea)
        rootContainer.flex.layout()
    }
    
    private func layout() {
        rootContainer.flex.direction(.column).padding(20).define { flex in
            flex.addItem(titleLabel).marginBottom(20)
            flex.addItem(policyTextView).grow(1).shrink(1)
        }
    }
}
