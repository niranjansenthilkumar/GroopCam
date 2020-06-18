//
//  MainController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/5/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MessageUI

class MainController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                
        collectionView?.register(GroupCell.self, forCellWithReuseIdentifier: cellId)
        
        layoutViews()
        
        if Auth.auth().currentUser == nil {
            //show if not logged in
            DispatchQueue.main.async {
                let viewController = ViewController()
//                viewController.modalPresentationStyle = .fullScreen
                let navController = UINavigationController(rootViewController: viewController)
                navController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                navController.navigationBar.shadowImage = UIImage()
                navController.navigationBar.isTranslucent = true
                navController.view.backgroundColor = UIColor.clear
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            
            return
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: AddFriendsController.updateFeedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: FriendsController.updateFriendNotificationName, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: UpdateFriendsController.updateAddFriendNotificationName, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: UsernameController.updateUserFeedNotificationName, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: VerificationCodeController.updateLoggedNotificationName, object: nil)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl

        fetchAllGroups()
        
    }
    
    var bool: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        if bool == false {
            NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: AddFriendsController.updateFeedNotificationName, object: nil)
            bool = true
        }
        
        
    }
    
    
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        print("Handling refresh..")
        groups.removeAll()
        fetchAllGroups()
        self.collectionView?.refreshControl?.endRefreshing()
    }
    
    var groups = [Group]()
    fileprivate func fetchAllGroups(){
        fetchGroups()
        self.collectionView.reloadData()
    }
    
    func fetchGroups(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        self.showSpinner(onView: self.collectionView)

        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchGroupsWithUser(user: user)
        }
        
    }
    
    var username: String = ""

    
    fileprivate func fetchGroupsWithUser(user: User){
//        print(user.groups, "please")
        username = user.username
                
        if user.groups.count == 0 {
            self.removeSpinner()
            self.collectionView.reloadData()
            return
        }

        for group in user.groups {
//            print(group, "please")
            var groupInfo = [] as [Any]
//            print(group.key, "please")
            Database.database().reference().child("groups").child(group.key).observeSingleEvent(of: .value) { (snapshot) in
//                print(snapshot.value, "please")

                if let value = snapshot.value as? [String: Any] {
                    guard let indgroupName = value["groupname"] else {return}
                    guard let indlastPicture = value["lastPicture"] else {return}
                    guard let indtimeStamp = value["timestamp"] else {return}

                    groupInfo.append(indgroupName)
                    groupInfo.append(indlastPicture)
                    groupInfo.append(indtimeStamp)

                }
                else{
                    self.removeSpinner()
                }
                
            Database.database().reference().child("members").child(group.key).observeSingleEvent(of: .value) { (snapshot) in
    //                print(snapshot.value, "please")
                    
//                    self.collectionView?.refreshControl?.endRefreshing()

                    if let value = snapshot.value as? [String: Any] {
                        print(value.count, "please")
                        let group = Group(groupid: group.key, groupname: groupInfo[0] as! String, lastPicture: groupInfo[1] as! String, creationDate: groupInfo[2] as! String, members: value, pics: [])
                        
                        self.groups.append(group)
                        
                        
                        self.groups.sort { (g1, g2) -> Bool in
                            let c1 = Date(timeIntervalSince1970: self.parseDuration(g1.lastPicture))
                            let c2 = Date(timeIntervalSince1970: self.parseDuration(g2.lastPicture))
                            return c1.compare(c2) == .orderedDescending
                            
                        }
                        
                        self.collectionView.reloadData()
                        self.removeSpinner()
                    }
                }
            }
        
        }
    }
    
    func parseDuration(_ timeString:String) -> TimeInterval {
        guard !timeString.isEmpty else {
            return 0
        }

        var interval:Double = 0

        let parts = timeString.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }

        return interval
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (self.groups.count == 0) {
            self.collectionView.setEmptyMessage("No group rolls yet! 😔 click new group to start a roll. 📸")
        } else {
            self.collectionView.restore()
        }
        
        return self.groups.count

        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 13, left: 0, bottom: 20, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 20, height: 64)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GroupCell
        
        let group = self.groups[indexPath.row]
        
        cell.label.text = group.groupname
                
        
        let timeString = parseDuration(group.lastPicture)
        let date = Date(timeIntervalSince1970: parseDuration(group.lastPicture))
        
        
        cell.recentLabel.text = "Active " + date.timeAgoDisplay()
        cell.groupNumberLabel.text = String(group.members.count)
        cell.cameraButton.tag = indexPath.row
        cell.cameraButton.addTarget(self, action: #selector(handleCamera(sender:)), for: .touchUpInside)
        
        cell.optionsButton.tag = indexPath.row
        cell.optionsButton.addTarget(self, action: #selector(handleDelete(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func handleDelete(sender: UIButton){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
        alert.addAction(UIAlertAction(title: "Leave Group", style: .destructive , handler:{ (UIAlertAction)in
            print("User click leave button")
            
//            do {
////
//            } catch let signOutErr {
//                print("Failed to sign out:", signOutErr)
//            }
            let data = self.groups[sender.tag]
            guard let userid = Auth.auth().currentUser?.uid else {return}

            
            Database.database().reference().child("members").child(data.groupid).child(userid).removeValue()
            Database.database().reference().child("users").child(userid).child("groups").child(data.groupid).removeValue()
        
            print("Successfully deleted user")
            self.groups.remove(at: sender.tag)

            
            self.collectionView.deleteItems(at: [IndexPath(row: sender.tag, section: 0)])
            self.handleRefresh()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        

        self.present(alert, animated: true, completion: {
            print("completion block")
        })    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        
        let groupRollVC = GroupRollController(collectionViewLayout: UICollectionViewFlowLayout())
        groupRollVC.group = self.groups[indexPath.row]
        
//        cameraController.username = self.username
        groupRollVC.username = self.username
        
        groupRollVC.groupCount = self.groups[indexPath.row].members.count
        self.navigationController?.pushNavBarWithTitle(vc: groupRollVC)
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    @objc func toggleSettings(){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Contact Me", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
            
            if !MFMailComposeViewController.canSendMail() {
                self.presentEmailServiceError()
                return
            }
            
            self.sendEmail()
            
        }))

        alert.addAction(UIAlertAction(title: "Invite Friends 😎", style: .default , handler:{ (UIAlertAction)in
            print("User click invite button")
            
            if !MFMessageComposeViewController.canSendText() {
                self.presentMessageServiceError()
                return
            }
            
            self.sendText()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive , handler:{ (UIAlertAction)in
            print("User click logout button")
            
            do {
                try Auth.auth().signOut()
                
                //what happens? we need to present some kind of login controller
                let viewController = ViewController()
                
                let navController = UINavigationController(rootViewController: viewController)
                navController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                navController.navigationBar.shadowImage = UIImage()
                navController.navigationBar.isTranslucent = true
                navController.view.backgroundColor = UIColor.clear
                navController.modalPresentationStyle = .fullScreen

                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func sendText() {
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = "Come join me on GroopCam, a social camera roll app 📸😎 https://apple.co/2S052xI"
                controller.recipients = []
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            //... handle sms screen actions
            self.dismiss(animated: true, completion: nil)
    }
    
    func presentMessageServiceError(){
            let alert = UIAlertController(title: "Message services are not available.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
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
    
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["ns633@cornell.edu"])
        composeVC.setSubject("GroopCam -")
        composeVC.setMessageBody("", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    
    func presentEmailServiceError(){
            let alert = UIAlertController(title: "Mail services are not available.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
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
        
    
    @objc func handleNewGroup(){
        let createGroupVC = CreateGroupController()
        self.navigationController?.pushNavBar(vc: createGroupVC)
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        
//        self.navigationItem.setBackImageEmpty()
    }
    
    @objc func handleCamera(sender: UIButton){
        
        let data = self.groups[sender.tag]
        
        print(data, "please")
    
        let cameraController = CameraController()
        cameraController.group = data
        cameraController.username = self.username
                                                
        let navVC = UINavigationController(rootViewController: cameraController)

        navVC.modalPresentationStyle = .fullScreen

        let height: CGFloat = 200 //whatever height you want to add to the existing height
        let bounds = navVC.navigationBar.bounds
        navVC.navigationBar.frame = CGRect(x: 0, y: 0, width: 50, height: bounds.height + height)
        
        navVC.setNavigationBarHidden(true, animated: false)

        self.present(navVC, animated: true, completion: nil)
        
    }
    
    func layoutViews(){
        collectionView.backgroundColor = Theme.backgroundColor
        setupNavBar()
        collectionView?.alwaysBounceVertical = true
    }
    
    fileprivate func setupNavBar(){
//        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.navigationBar.barTintColor = Theme.lgColor
        self.navigationController?.navigationBar.topItem?.title = "Group Rolls"
//
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = Theme.backgroundColor

//
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.bold)]
    
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settingsicon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(toggleSettings))
//        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settingsicon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(toggleSettings))
        
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "newgroupicon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleNewGroup))
    
    }
}

extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
//            let user = User(uid: uid, dictionary: userDictionary)
            
            let groups = userDictionary["groups"] as? [String : Any] ?? [:]
            
            let user = User(uid: uid, username: userDictionary["username"] as! String, phonenumber: userDictionary["phonenumber"] as! String, groups: groups)
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user for posts:", err)
        }
    }
}
