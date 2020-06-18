//
//  UsernameController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/5/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UsernameController: UIViewController, UITextFieldDelegate {
    
    var phoneNumber: String = ""
    
    let submitButton: UIButton = {
        let button = UIButton().setupButton(backgroundColor: Theme.buttonColor, title: "Submit", titleColor: .white, ofSize: 25, weight: UIFont.Weight.medium, cornerRadius: 15)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    lazy var usernameField: UITextField = {
        let field = UITextField().setupTextField(backgroundColor: .white, ofSize: 30, weight: UIFont.Weight.medium, cornerRadius: 10, keyboardType: .alphabet, textAlignment: .center, keyboardAppearance: .light, textColor: .black)
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        return field
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 40, weight: UIFont.Weight.medium, textColor: .white, text: "Choose your username.", textAlignment: .left)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        layoutViews()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let whitespaceSet = CharacterSet.whitespaces
        if let _ = string.rangeOfCharacter(from: whitespaceSet) {
            return false
        }
        
        if let _ = string.rangeOfCharacter(from: .uppercaseLetters) {
            // Don't allow upper case letters
            return false
        }
        else {
            return true
        }
    }
    
    static let updateUserFeedNotificationName = NSNotification.Name(rawValue: "UpdateUserFeed")
    
    @objc func handleNext(){
        submitButton.animateButtonDown()
        
        let activityIndicator = UIActivityIndicatorView()
        self.submitButton.setTitle("", for: .normal)
        self.submitButton.addSubview(activityIndicator)
        activityIndicator.anchor(top: self.submitButton.topAnchor, left: self.submitButton.leftAnchor, bottom: self.submitButton.bottomAnchor, right: self.submitButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        activityIndicator.startAnimating()
        
        guard let username = usernameField.text else { return }
        let uid = UserDefaults.standard.string(forKey: "userid")
        let phoneNumber = self.phoneNumber
        
//        print(self.phoneNumber, "please")
//        print(UserDefaults.standard.string(forKey: "userid"), "please")
        let mainController = MainController(collectionViewLayout: UICollectionViewFlowLayout())
        
        if username.count > 2 {
            let dictionaryValues = ["username": username, "phonenumber": phoneNumber]
            let values = [uid: dictionaryValues]

            Database.database().reference().child("users").updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to save user info into db:", err)
                    return
                }
                
                print("Successfully saved user info to db")
                
//                let phonevalues = ["uid": uid, "username": username, "phonenumber": phoneNumber]
//                let phoneNumberValues = [phoneNumber: phonevalues]
//            Database.database().reference().child("contacts").updateChildValues(phoneNumberValues) { (err, ref) in
//                if let err = err {
//                    print("Failed to save phone number into db:", err)
//                    return
//                }
//
//                print("Successfully saved phone number info to db")
            }
            
            let phonevalues = ["uid": uid, "username": username, "phonenumber": phoneNumber]
            let phoneNumberValues = [phoneNumber: phonevalues]
        Database.database().reference().child("contacts").updateChildValues(phoneNumberValues) { (err, ref) in
            if let err = err {
                print("Failed to save phone number into db:", err)
                return
            }
            
            print("Successfully saved phone number info to db")
            
            activityIndicator.stopAnimating()
            self.submitButton.setTitle("Submit", for: .normal)
            
            let navVC = UINavigationController(rootViewController: mainController)

            navVC.modalPresentationStyle = .fullScreen

            navVC.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navVC.navigationBar.shadowImage = UIImage()
            
            NotificationCenter.default.post(name: UsernameController.updateUserFeedNotificationName, object: nil)
            
            self.dismiss(animated: true, completion: nil)
            
            }
        }
        else {
            activityIndicator.stopAnimating()
            self.submitButton.setTitle("Submit", for: .normal)
            presentFailedUsername()
        }

        //fix navigation bug here!!!!!!!

        
//        self.present(navVC, animated: true, completion: nil)
        
//        guard let mainControllerVC = UIApplication.shared.keyWindow?.rootViewController as? MainController else { return }
        
        
        
        
    }

    
    func presentFailedUsername(){
        let alert = UIAlertController(title: "Username must be longer than 2 characters.", message: "", preferredStyle: .alert)
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
    
    func layoutViews(){
        self.view.backgroundColor = Theme.backgroundColor
        
        self.view.addSubview(submitButton)
        submitButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        submitButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        submitButton.anchor(top: nil, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 66)
       
        self.view.addSubview(usernameField)
        usernameField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        usernameField.anchor(top: nil, left: self.view.leftAnchor, bottom: self.submitButton.topAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 23, paddingRight: 12, width: 0, height: 58)
    
        usernameField.becomeFirstResponder()
       
        self.view.addSubview(usernameLabel)
        usernameLabel.anchor(top: nil, left: submitButton.leftAnchor, bottom: usernameField.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 23, paddingRight: 0, width: 224, height: 96)

    }
}

