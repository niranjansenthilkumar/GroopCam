//
//  EditGroupController.swift
//  GroopCam
//
//  Created by Aliva Das on 7/3/20.
//  Copyright © 2020 NJ. All rights reserved.
//
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class EditGroupController: UIViewController {
    
    var groupId: String?
    var lastPic: String?
    var timeStamp: String?

    let editGroupButton: UIButton = {
        let button = UIButton().setupButton(backgroundColor: Theme.buttonColor, title: "Update", titleColor: .white, ofSize: 25, weight: UIFont.Weight.medium, cornerRadius: 15)
        button.addTarget(self, action: #selector(handleUpdate), for: .touchUpInside)
        return button
    }()
    
    let groupField: UITextField = {
        let field = UITextField().setupTextField(backgroundColor: .white, ofSize: 30, weight: UIFont.Weight.medium, cornerRadius: 10, keyboardType: .default, textAlignment: .center, keyboardAppearance: .light, textColor: .black)
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        return field
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 30, weight: UIFont.Weight.medium, textColor: .white, text: "Edit Group Name", textAlignment: .center)
        return label
    }()
    
    let lenLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 20, weight: UIFont.Weight.light, textColor: .white, text: "(max 80 chars.)", textAlignment: .center)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
    }
    
    func layoutViews(){
        self.view.backgroundColor = Theme.backgroundColor
        
        self.view.addSubview(editGroupButton)
        editGroupButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        editGroupButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        editGroupButton.anchor(top: nil, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 66)
        
        self.view.addSubview(lenLabel)
        lenLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        lenLabel.anchor(top: nil, left: self.view.leftAnchor, bottom: self.editGroupButton.topAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 2, paddingRight: 12, width: 0, height: 58)
       
        self.view.addSubview(groupField)
        groupField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        groupField.anchor(top: nil, left: self.view.leftAnchor, bottom: self.lenLabel.topAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 2, paddingRight: 12, width: 0, height: 58)
    
        groupField.becomeFirstResponder()
       
        self.view.addSubview(nameLabel)
        nameLabel.anchor(top: nil, left: editGroupButton.leftAnchor, bottom: groupField.topAnchor, right: editGroupButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 23, paddingRight: 0, width: 0, height: 43)

    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    static let updateGroupName = Notification.Name("updateGroupName")
    
    @objc func handleUpdate(){
        
        let activityIndicator = UIActivityIndicatorView()
        self.editGroupButton.setTitle("", for: .normal)
        self.editGroupButton.addSubview(activityIndicator)
        activityIndicator.anchor(top: self.editGroupButton.topAnchor, left: self.editGroupButton.leftAnchor, bottom: self.editGroupButton.bottomAnchor, right: self.editGroupButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        activityIndicator.startAnimating()
        
        guard let groupName = groupField.text else { return }

        editGroupButton.animateButtonDown()


        print(groupName, "please")

        if groupName.count > 3 && groupName.count <= 80 {
            print("please")

           let dictionaryValues = ["groupname": groupName, "timestamp": timeStamp, "lastPicture": lastPic]

            let values = [groupId: dictionaryValues]
                   

               Database.database().reference().child("groups").updateChildValues(values) { (err, ref) in
                       if let err = err {
                           print("Failed to save group info into db:", err)
                           return
                       }

                       print("Successfully saved group info to db")

                   }
            
            activityIndicator.stopAnimating()
            self.editGroupButton.setTitle("Update", for: .normal)
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: EditGroupController.updateGroupName, object: nil, userInfo:["groupName": groupName])
           // handled by viewWillAppear in Main Controller
           // NotificationCenter.default.post(name: EditGroupController.updateFeedNotificationName, object: nil)
            
        }
        else{
            presentFailedGroupName(charLength: groupName.count)
            activityIndicator.stopAnimating()
            self.editGroupButton.setTitle("Update", for: .normal)

        }
    }
    
    func presentFailedGroupName(charLength: Int){
        
        var alertTitle = ""
        var mes = ""
        if charLength <= 3 {
           alertTitle = "Group name must be longer than 3 characters."
        }
        else {
            alertTitle = "Group name must not greater than 80 characters."
            mes = "Delete "+String(charLength-80)+" characters."
        }
        let alert = UIAlertController(title: alertTitle, message: mes, preferredStyle: .alert)
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

}

