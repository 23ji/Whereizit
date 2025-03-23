//
//  LoginViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 3/20/25.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        
        // Auto Layout 설정
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 150),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    
    @objc func loginButtonTapped(_ sender: UIButton) {
        print("로그인 버튼 눌림")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let VC = storyboard.instantiateViewController(withIdentifier: "VC") as? ViewController {
            VC.modalPresentationStyle = .fullScreen
            present(VC, animated: true, completion: nil)
        } else {
            print("ViewController를 찾을 수 없음")
        }
    }
}
