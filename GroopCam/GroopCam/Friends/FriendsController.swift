//
//  FriendsController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/9/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FriendsController: UITableViewController, UIActionSheetDelegate {
    
    var group: Group?
    
    var contactsToNotAdd: [String] = []
    
    let cellIdentifier: String = "tableCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupNavBar()
        setupTableView()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView?.refreshControl = refreshControl

        fetchMembers()
                
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        print("Handling refresh..")
    
        self.friendToDisplay.removeAll()
        fetchMembers()
        
    }
    
    var friendToDisplay = [FriendToDisplay]()
    
    
    
    func fetchMembers(){
        guard let members = self.group?.members else {return}
        
        for member in members{
            Database.database().reference().child("users").child(member.key).observeSingleEvent(of: .value) { (snapshot) in
                    
                    if let value = snapshot.value as? [String: Any] {

                        guard let username = value["username"] else {return}
                        guard let phoneNumber = value["phonenumber"] else {return}
                        
                        let usernameToAdd = username as? String ?? ""
                        let phoneNumberToAdd = phoneNumber as? String ?? ""
                        
                        let friend = FriendToDisplay(phonenumber: phoneNumberToAdd, username: usernameToAdd)
                        
//                        print(usernameToAdd, "please")
//                        print(phoneNumberToAdd, "please")
                        
                        self.friendToDisplay.append(friend)
                        self.tableView.reloadData()
                        self.contactsToNotAdd.append(phoneNumberToAdd)
                    }
            }
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendToDisplay.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendCell
        
        let friend = self.friendToDisplay[indexPath.row]
        
        print(friend.phonenumber, "please")
        
        cell.label.text = "@" + friend.username
        cell.usernameLabel.text = friend.phonenumber

        cell.selectionStyle = .none
        
        return cell
    }
    
    @objc func handleAddFriends(){
        let updateFriendsVC = UpdateFriendsController()
        updateFriendsVC.contactsToNotAdd = self.contactsToNotAdd
        print(self.contactsToNotAdd, "pleasee")
        updateFriendsVC.groupId = self.group?.groupid ?? ""
        self.navigationController?.pushNavBarWithTitle(vc: updateFriendsVC)
        self.navigationItem.setBackImageEmpty()
    }
    
    static let updateFriendNotificationName = NSNotification.Name(rawValue: "UpdateFriendFeed")
    
    @objc func toggleSettings(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Edit Group Name", style: .default , handler:{ (UIAlertAction)in
                           print("User click edit group button")
                
            guard let groupId = self.group?.groupid else {return}
            guard let lastPic = self.group?.lastPicture else {return}
            guard let timeStamp = self.group?.creationDate else {return}
                   
            let editGroupVC = EditGroupController()
            editGroupVC.groupId = groupId
            editGroupVC.lastPic = lastPic
            editGroupVC.timeStamp = timeStamp
            self.navigationController?.pushNavBar(vc: editGroupVC)
                                  
            self.navigationItem.leftItemsSupplementBackButton = true
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                           
        }))
                        
        alert.addAction(UIAlertAction(title: "Leave Group", style: .destructive , handler:{ (UIAlertAction)in
            print("User click Delete button")
            
            guard let groupID = self.group?.groupid else {return}
            
            guard let userid = Auth.auth().currentUser?.uid else {return}
            
            Database.database().reference().child("members").child(groupID).child(userid).removeValue()
                Database.database().reference().child("users").child(userid).child("groups").child(groupID).removeValue()
            
            
            NotificationCenter.default.post(name: FriendsController.updateFriendNotificationName, object: nil)

            self.navigationController?.popToRootViewController(animated: true)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    
    fileprivate func setupNavBar(){
        self.navigationItem.title = "Friends"
                
        self.navigationItem.rightBarButtonItems =         [UIBarButtonItem(image: UIImage(named: "settingsicon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(toggleSettings)), UIBarButtonItem(image: UIImage(named: "addfriendsicon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddFriends))]
        
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.barTintColor = Theme.backgroundColor

    }
    
    fileprivate func setupTableView(){
        
        self.tableView.backgroundView?.backgroundColor = Theme.backgroundColor
     
        tableView.register(FriendCell.self, forCellReuseIdentifier: cellIdentifier)
        

        tableView.allowsMultipleSelection = true
        
        tableView.backgroundColor = Theme.backgroundColor
        self.tableView.backgroundView = UIView()
        tableView.tableFooterView = UIView()
    }
    
}


