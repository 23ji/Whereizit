//
//  FullImageViewController.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 10/27/25.
//

import UIKit
import Then
import PinLayout

final class FullImageViewController: UIViewController {
  
  private let image: UIImage?
  
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.backgroundColor = .black
    $0.isUserInteractionEnabled = true
  }
  
  private let closeButton = UIButton(type: .system).then {
    $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
    $0.tintColor = .white
    $0.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    $0.layer.cornerRadius = 20
    $0.clipsToBounds = true
  }
  
  // MARK: - Init
  init(image: UIImage?) {
    self.image = image
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .black
    
    self.view.addSubview(imageView)
    self.view.addSubview(closeButton)
    
    self.imageView.image = image
    self.closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    imageView.pin.all()
    closeButton.pin
      .top(view.pin.safeArea.top + 16)
      .right(16)
      .width(40)
      .height(40)
  }
  
  // MARK: - Actions
  @objc private func dismissView() {
    dismiss(animated: true)
  }
}
