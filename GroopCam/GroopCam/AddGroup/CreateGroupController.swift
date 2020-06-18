//
//  CreateGroupController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/6/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit

class CreateGroupController: UIViewController {
    
    let createGroupButton: UIButton = {
        let button = UIButton().setupButton(backgroundColor: Theme.buttonColor, title: "Next", titleColor: .white, ofSize: 25, weight: UIFont.Weight.medium, cornerRadius: 15)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    let groupField: UITextField = {
        let field = UITextField().setupTextField(backgroundColor: .white, ofSize: 30, weight: UIFont.Weight.medium, cornerRadius: 10, keyboardType: .default, textAlignment: .center, keyboardAppearance: .light, textColor: .black)
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        return field
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 30, weight: UIFont.Weight.medium, textColor: .white, text: "Name your camera roll.", textAlignment: .center)
        return label
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutViews()
    }

    @objc func handleNext(){
        
        let activityIndicator = UIActivityIndicatorView()
        self.createGroupButton.setTitle("", for: .normal)
        self.createGroupButton.addSubview(activityIndicator)
        activityIndicator.anchor(top: self.createGroupButton.topAnchor, left: self.createGroupButton.leftAnchor, bottom: self.createGroupButton.bottomAnchor, right: self.createGroupButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        activityIndicator.startAnimating()
        
        guard let groupName = groupField.text else { return }

        createGroupButton.animateButtonDown()


        print(groupName, "please")

        if groupName.count > 3 {
            print("please")
            let addFriendsVC = AddFriendsController()
            addFriendsVC.groupName = groupName
            activityIndicator.stopAnimating()
            self.createGroupButton.setTitle("Next", for: .normal)
            self.navigationController?.pushNavBarWithTitle(vc: addFriendsVC)
            self.navigationItem.setBackImageEmpty()
        }
        else{
            presentFailedGroupName()
            activityIndicator.stopAnimating()
            self.createGroupButton.setTitle("Next", for: .normal)

        }
        
    }
    
    func presentFailedGroupName(){
        let alert = UIAlertController(title: "Group name must be longer than 3 characters.", message: "", preferredStyle: .alert)
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
        
        self.view.addSubview(createGroupButton)
        createGroupButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        createGroupButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        createGroupButton.anchor(top: nil, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 66)
       
        self.view.addSubview(groupField)
        groupField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        groupField.anchor(top: nil, left: self.view.leftAnchor, bottom: self.createGroupButton.topAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 23, paddingRight: 12, width: 0, height: 58)
    
        groupField.becomeFirstResponder()
       
        self.view.addSubview(nameLabel)
        nameLabel.anchor(top: nil, left: createGroupButton.leftAnchor, bottom: groupField.topAnchor, right: createGroupButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 23, paddingRight: 0, width: 0, height: 43)

    }

}
