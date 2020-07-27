//
//  Extensions.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/5/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import Foundation


extension UINavigationController {
    func pushNavBar(vc: UIViewController){
        
        vc.navigationItem.titleView = UIImageView()
        
        self.pushViewController(vc, animated: true)
        
        
        let imgBackArrow = UIImage(named: "backbutton")
        
        self.navigationBar.backIndicatorImage = imgBackArrow
        self.navigationBar.backIndicatorTransitionMaskImage = imgBackArrow
        
        self.navigationBar.tintColor = UIColor.white
    }
    
    func pushNavBarWithTitle(vc: UIViewController){
        
        self.pushViewController(vc, animated: true)
        
        
        let imgBackArrow = UIImage(named: "backbutton")
        
        self.navigationBar.backIndicatorImage = imgBackArrow
        self.navigationBar.backIndicatorTransitionMaskImage = imgBackArrow
        self.navigationBar.tintColor = UIColor.white
    }

}

extension UINavigationItem {
    func setBackImageEmpty(){
        self.leftItemsSupplementBackButton = true
        self.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

extension UILabel{
    func setupLabel(ofSize: CGFloat, weight: UIFont.Weight, textColor: UIColor, text: String, textAlignment: NSTextAlignment) -> UILabel {
        self.font = .systemFont(ofSize: ofSize, weight: weight)
        self.text = text
        self.textColor = textColor
        self.textAlignment = textAlignment
        return self
    }
}

extension UIButton{
    func setupButton(backgroundColor: UIColor, title: String, titleColor: UIColor, ofSize: CGFloat, weight: UIFont.Weight, cornerRadius: CGFloat) -> UIButton {
        self.backgroundColor = backgroundColor
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: ofSize, weight: weight)
        self.layer.cornerRadius = cornerRadius
        return self
    }
}

extension Data
{
    func toString() -> String
    {
        return String(data: self, encoding: .utf8)!
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

extension UIView {

func animateButtonDown() {

    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }, completion: nil)
    
    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
        self.transform = CGAffineTransform.identity
    }, completion: nil)
    }
}

extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel()
//            UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 64, height: self.bounds.size.height))
        
        messageLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width - 64, height: self.bounds.size.height)
//        messageLabel.anchor(top: backgroundView?.topAnchor, left: backgroundView?.leftAnchor, bottom: backgroundView?.bottomAnchor, right: backgroundView?.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 312, height: 137)
//        messageLabel.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 312, height: 137)
        
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = .systemFont(ofSize: 36, weight: UIFont.Weight.medium)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel()
//            UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 64, height: self.bounds.size.height))
        
        messageLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width - 64, height: self.bounds.size.height)
//        messageLabel.anchor(top: backgroundView?.topAnchor, left: backgroundView?.leftAnchor, bottom: backgroundView?.bottomAnchor, right: backgroundView?.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 312, height: 137)
//        messageLabel.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 312, height: 137)
        
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = .systemFont(ofSize: 36, weight: UIFont.Weight.medium)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }

}


extension UITextField{
    func setupTextField(backgroundColor: UIColor, ofSize: CGFloat, weight: UIFont.Weight, cornerRadius: CGFloat, keyboardType: UIKeyboardType, textAlignment: NSTextAlignment, keyboardAppearance: UIKeyboardAppearance, textColor: UIColor) -> UITextField {
        
        self.backgroundColor = backgroundColor
        self.font = .systemFont(ofSize: ofSize, weight: weight)
        self.layer.cornerRadius = cornerRadius
        self.keyboardType = keyboardType
        self.textAlignment = textAlignment
        self.keyboardAppearance = keyboardAppearance
        self.textColor = textColor
        
        return self
    }
}


extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0

        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }

        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)

        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}

extension CALayer {
  func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.5,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0)
  {
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}

public extension UIView {

  /**
  Fade in a view with a duration

  - parameter duration: custom animation duration
  */
    func fadeIn(duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            self.layoutIfNeeded()
            self.alpha = 1.0
            self.setNeedsLayout()
    })
  }

  /**
  Fade out a view with a duration

  - parameter duration: custom animation duration
  */
    func fadeOut(duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            self.layoutIfNeeded()
            self.alpha = 0.75
            self.setNeedsLayout()
    })
  }

}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        let year = 12 * month
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else if secondsAgo < year {
            quotient = secondsAgo / month
            unit = "month"
        } else {
            quotient = secondsAgo / year
            unit = "year"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
        
    }
}
