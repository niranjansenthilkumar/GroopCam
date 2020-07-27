//
//  VerificationCodeController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/5/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class VerificationCodeController: UIViewController {
    
    var phoneNumber: String = ""
    
    let verifyCodeButton: UIButton = {
        let button = UIButton().setupButton(backgroundColor: Theme.buttonColor, title: "Verify", titleColor: .white, ofSize: 25, weight: UIFont.Weight.medium, cornerRadius: 15)
        button.addTarget(self, action: #selector(handleVerifyCode), for: .touchUpInside)
        return button
    }()
    
    let verificationField: UITextField = {
        let field = UITextField().setupTextField(backgroundColor: .white, ofSize: 30, weight: UIFont.Weight.medium, cornerRadius: 10, keyboardType: .phonePad, textAlignment: .center, keyboardAppearance: .light, textColor: .black)
        return field
    }()
    
    let codeLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 40, weight: UIFont.Weight.medium, textColor: .white, text: "Enter the verification code.", textAlignment: .left)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutViews()
        
    }
    
    static let updateLoggedNotificationName = NSNotification.Name(rawValue: "UpdateLoggedFeed")

    
    @objc func handleVerifyCode(){
        
        let activityIndicator = UIActivityIndicatorView()
        self.verifyCodeButton.setTitle("", for: .normal)
        self.verifyCodeButton.addSubview(activityIndicator)
        activityIndicator.anchor(top: self.verifyCodeButton.topAnchor, left: self.verifyCodeButton.leftAnchor, bottom: self.verifyCodeButton.bottomAnchor, right: self.verifyCodeButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        activityIndicator.startAnimating()
        
        verifyCodeButton.animateButtonDown()
        
        guard let verificationID = UserDefaults.standard.string(forKey: "firebase_verification") else {return}
        
        guard let verificationCode = verificationField.text, verificationCode.count > 0 else { return }
        
        let credential = PhoneAuthProvider.provider().credential(
        withVerificationID: verificationID,
        verificationCode: verificationCode)
        
        if let user = Auth.auth().currentUser {
            user.link(with: credential) { (user, error) in
                let usernameVC = UsernameController()
                usernameVC.phoneNumber = self.phoneNumber
                self.navigationController?.pushNavBar(vc: usernameVC)
                self.navigationItem.setBackImageEmpty()
                
                UserDefaults.standard.set(user?.user.uid, forKey: "userid")
                UserDefaults.standard.synchronize()
            }
        }
        
        if Auth.auth().currentUser == nil {
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    self.presentFailedVerification()
                    activityIndicator.stopAnimating()
                    self.verifyCodeButton.setTitle("Verify", for: .normal)
                    return
                }
                
                guard let uid = authResult?.user.uid else {return}
                
                Database.database().reference().child("users").observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.hasChild(uid){
                        print("phonenumber exists")

                        activityIndicator.stopAnimating()
                        self.verifyCodeButton.setTitle("Verify", for: .normal)

                        
                        let mainController = MainController(collectionViewLayout: UICollectionViewFlowLayout())
                        
                        let navVC = UINavigationController(rootViewController: mainController)

                        navVC.modalPresentationStyle = .fullScreen

                        navVC.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                        navVC.navigationBar.shadowImage = UIImage()
                        
                        NotificationCenter.default.post(name: VerificationCodeController.updateLoggedNotificationName, object: nil)

                        self.dismiss(animated: true, completion: nil)
                    }
                    else{
                        print("phonenumber is new")
                        
                        let usernameVC = UsernameController()
                        usernameVC.phoneNumber = self.phoneNumber
                        self.navigationController?.pushNavBar(vc: usernameVC)
                        self.navigationItem.setBackImageEmpty()
                        
                        UserDefaults.standard.set(uid, forKey: "userid")
                        UserDefaults.standard.synchronize()
                    }
                }
            }
            
        }
        
    }
    
    func presentFailedVerification(){
        let alert = UIAlertController(title: "Invalid code.", message: "", preferredStyle: .alert)
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
        
        self.view.addSubview(verifyCodeButton)
        verifyCodeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        verifyCodeButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        verifyCodeButton.anchor(top: nil, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 66)
       
        self.view.addSubview(verificationField)
        verificationField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        verificationField.anchor(top: nil, left: self.view.leftAnchor, bottom: self.verifyCodeButton.topAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 23, paddingRight: 12, width: 0, height: 58)
    
        verificationField.becomeFirstResponder()
       
        self.view.addSubview(codeLabel)
        codeLabel.anchor(top: nil, left: verifyCodeButton.leftAnchor, bottom: verificationField.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 23, paddingRight: 0, width: 355, height: 96)
    }
}
