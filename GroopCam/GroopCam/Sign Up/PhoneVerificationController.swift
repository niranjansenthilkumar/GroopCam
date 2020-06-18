//
//  PhoneVerificationController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/5/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth


class PhoneVerificationController: UIViewController, UITextFieldDelegate {
    
    let sendCodeButton: UIButton = {
        let button = UIButton().setupButton(backgroundColor: Theme.buttonColor, title: "Send Code", titleColor: .white, ofSize: 25, weight: UIFont.Weight.medium, cornerRadius: 15)
        button.addTarget(self, action: #selector(handleSendCode), for: .touchUpInside)
        return button
    }()
    
    let phoneField: UITextField = {
        let field = UITextField().setupTextField(backgroundColor: .white, ofSize: 30, weight: UIFont.Weight.medium, cornerRadius: 10, keyboardType: .phonePad, textAlignment: .center, keyboardAppearance: .light, textColor: .black)
        return field
    }()
    
    let phonenumberLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 40, weight: UIFont.Weight.medium, textColor: .white, text: "Enter your phone number.", textAlignment: .left)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
    }
    
    
    
    @objc func handleSendCode(){
        guard let ogphoneNumber = phoneField.text, ogphoneNumber.count > 0 else { return }


        var phoneNumber = ogphoneNumber.components(separatedBy:CharacterSet.decimalDigits.inverted).joined()

        if phoneNumber.count == 10 {
            print("+1" + phoneNumber)
            phoneNumber = "+1" + phoneNumber
        }
        else{
            print("+" + phoneNumber)
            phoneNumber = "+" + phoneNumber
        }
//        print(phoneNumber.count)
//        phoneNumber = "+" + phoneNumber
//        print(phoneNumber)
        
        let activityIndicator = UIActivityIndicatorView()
        self.sendCodeButton.setTitle("", for: .normal)
        self.sendCodeButton.addSubview(activityIndicator)
        activityIndicator.anchor(top: self.sendCodeButton.topAnchor, left: self.sendCodeButton.leftAnchor, bottom: self.sendCodeButton.bottomAnchor, right: self.sendCodeButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        activityIndicator.startAnimating()

        sendCodeButton.animateButtonDown()

//        let phoneNumber = "5"
//        phoneNumber = "+1 203-722-4638"
//        phoneNumber = "+1 650-555-4438"

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if error != nil {
                self.presentFailedPhoneNumber()
                activityIndicator.stopAnimating()
                self.sendCodeButton.setTitle("Send Code", for: .normal)
                print(phoneNumber, "failed")
                print(error)
                return
            }
            print(verificationID, "please")
            activityIndicator.stopAnimating()
            self.sendCodeButton.setTitle("Send Code", for: .normal)
            let verificationVC = VerificationCodeController()
            verificationVC.phoneNumber = phoneNumber
            self.navigationController?.pushNavBar(vc: verificationVC)
            self.navigationItem.setBackImageEmpty()

            UserDefaults.standard.set(verificationID, forKey: "firebase_verification")
            UserDefaults.standard.synchronize()
            
//            print(UserDefaults.standard.string(forKey: "firebase_verification"), "please")
        }

    }
    
    func presentFailedPhoneNumber(){
        let alert = UIAlertController(title: "Please enter a valid phone number.", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
              switch action.style{
              case .default:
                    print("default")

              case .cancel:
                    print("cancel")

              case .destructive:
                    print("destructive")


        }}))
        self.present(alert, animated: true, completion: nil)

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if (textField == phoneField) {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: NSCharacterSet.decimalDigits.inverted)

            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.hasPrefix("1")

            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int

                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()

            if hasLeadingOne {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3 {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }

            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            return false
        }
        else {
            return true
        }
    }
    
    func layoutViews(){
       self.view.backgroundColor = Theme.backgroundColor

       self.view.addSubview(sendCodeButton)
       sendCodeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
       sendCodeButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
       sendCodeButton.anchor(top: nil, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 66)
       
       self.view.addSubview(phoneField)
       phoneField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
       phoneField.anchor(top: nil, left: self.view.leftAnchor, bottom: self.sendCodeButton.topAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 23, paddingRight: 12, width: 0, height: 58)
    
       phoneField.delegate = self
       phoneField.becomeFirstResponder()

       
       self.view.addSubview(phonenumberLabel)
       phonenumberLabel.anchor(top: nil, left: sendCodeButton.leftAnchor, bottom: phoneField.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 23, paddingRight: 0, width: 270, height: 96)
    }
}
