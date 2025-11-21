//
//  Color.swift
//  Whereizit
//
//  Created by 23ji on 11/9/25.
//

import UIKit

extension UIColor {

  static let smokingColor = UIColor(named: "smokingColor")
  static let trashColor = UIColor(named: "trashColor")
  static let toiletColor = UIColor(named: "toiletColor")
  static let waterColor = UIColor(named: "waterColor")

  convenience init(hexCode: String, alpha: CGFloat = 1.0) {
    var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

    if hexFormatted.hasPrefix("#") {
      hexFormatted = String(hexFormatted.dropFirst())
    }

    assert(hexFormatted.count == 6, "Invalid hex code used.")

    var rgbValue: UInt64 = 0
    Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
              alpha: alpha)
  }
}
