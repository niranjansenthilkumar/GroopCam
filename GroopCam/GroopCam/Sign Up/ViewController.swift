//
//  ViewController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/5/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 50, weight: UIFont.Weight.heavy, textColor: .white, text: "GroopCam", textAlignment: .left)
        return label
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 25, weight: UIFont.Weight.medium, textColor: .white, text: "take pics with friends 📸", textAlignment: .left)
        return label
    }()
    
    let startButton: UIButton = {
        let button = UIButton().setupButton(backgroundColor: Theme.buttonColor, title: "Get Started", titleColor: .white, ofSize: 25, weight: UIFont.Weight.medium, cornerRadius: 15)
        button.addTarget(self, action: #selector(handleStart), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        layoutViews()
    }
    
    @objc func handleStart(){
        startButton.animateButtonDown()
        let phoneVC = PhoneVerificationController()
        self.navigationController?.pushNavBar(vc: phoneVC)
        self.navigationItem.setBackImageEmpty()
    }
    
    func layoutViews(){

        self.view.backgroundColor = Theme.backgroundColor
        
        self.view.addSubview(startButton)
        startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        startButton.anchor(top: nil, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 60, paddingRight: 12, width: 0, height: 66)
        
        self.view.addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: startButton.leftAnchor, bottom: startButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 52, paddingRight: 0, width: 0, height: 0)
        
        self.view.addSubview(captionLabel)
        captionLabel.anchor(top: nil, left: startButton.leftAnchor, bottom: startButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 2, paddingBottom: 12, paddingRight: 0, width: 0, height: 0)

    }
    

}
