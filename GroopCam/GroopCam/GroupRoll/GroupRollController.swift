//
//  GroupRollController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/7/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class GroupRollController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var group: Group?
    var groupCount: Int = 0
    
    var objects : [PrintableObject] = []
    
    var isSelected: Bool = false

    let cellId = "cellId"
    
    let printButton: UIButton = {
        let button = UIButton().setupButton(backgroundColor: Theme.buttonColor, title: "Print photos 🏞", titleColor: .white, ofSize: 18, weight: UIFont.Weight.medium, cornerRadius: 15)
        button.addTarget(self, action: #selector(handlePrintPhotos), for: .touchUpInside)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.alpha = 1.0
        button.isEnabled = true
        return button
    }()
    
    let actualPrintButton: UIButton = {
        let button = UIButton().setupButton(backgroundColor: Theme.buttonColor, title: "Print photos 🏞", titleColor: .white, ofSize: 18, weight: UIFont.Weight.medium, cornerRadius: 15)
        button.addTarget(self, action: #selector(handleActualPrintPhotos), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 1.0
        return button
    }()
    
    let friendButton: UIButton = {
        let button = UIButton().setupButton(backgroundColor: Theme.buttonColor, title: "1 friend 👥", titleColor: .white, ofSize: 20, weight: UIFont.Weight.medium, cornerRadius: 15)
        button.addTarget(self, action: #selector(handleFriends), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(GroupRollCell.self, forCellWithReuseIdentifier: cellId)
        layoutViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: CameraController.updateGroopFeedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: PictureController.updatePictureNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupNameFunc(notification:)), name: EditGroupController.updateGroupName, object: nil)
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        guard let groupId = self.group?.groupid else {return}
        
        
//        cell.groopImage.loadImage(urlString: post.imageUrl)
//
//        for post in self.posts{
//            let cv = CustomImageView()
//            cv.loadImage(urlString: post.imageUrl)
//            guard let image = cv.image else {return}
//
//            self.objects.append(PrintableObject(isSelectedByUser: false, post: post, image: image))
//        }
        self.showSpinner(onView: self.collectionView)

        fetchPostsWithGroupID(groupID: groupId)
        
        
        print(groupCount, "pleeeeease")
        if groupCount == 1 {
            self.friendButton.setTitle(String(groupCount) + " friend 👥", for: .normal)
        }
        else{
            self.friendButton.setTitle(String(groupCount) + " friends 👥", for: .normal)
        }
        
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        
        print("Handling refresh..")
        guard let groupId = self.group?.groupid else {return}
        self.posts.removeAll()
        self.objects.removeAll()
        fetchPostsWithGroupID(groupID: groupId)
        
        
        if self.posts.count == 0 && self.objects.count == 0 {
            self.removeSpinner()
            self.collectionView.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
            return
        }
        
    }
    
    var posts = [Picture]()
    fileprivate func fetchPostsWithGroupID(groupID: String) {
        
        Database.database().reference().child("posts").child(groupID).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else {
                self.removeSpinner()
                return }

            
            dictionaries.forEach { (key, value) in
                guard let dictionary = value as? [String : Any] else {return}
                
                print(key, value)
                
                let userIDToAdd = dictionary["userid"] as? String ?? ""
                
                print(userIDToAdd, "please")
                
                let creationDateToAdd = dictionary["creationDate"] as? String? ?? ""
                
                guard let groupName = dictionary["groupname"] else {return}
                let groupNameToAdd = groupName as? String ?? ""
                
                guard let imageURL = dictionary["imageUrl"] else {return}
                let imageURLToAdd = imageURL as? String ?? ""
                
                Database.database().reference().child("users").child(userIDToAdd).observeSingleEvent(of: .value) { (usersnapshot) in
                    
                    guard let userDictionary = usersnapshot.value as? [String: Any] else { return }

                    print(userDictionary, "please")
                    
                    let usernameToAdd = userDictionary["username"] as? String ?? ""
                    
                    let phonenumberToAdd = userDictionary["phonenumber"] as? String ?? ""

                    let groups = userDictionary["groups"] as? [String : Any] ?? [:]

                    
                    let userToAdd = User(uid: userIDToAdd, username: usernameToAdd, phonenumber: phonenumberToAdd, groups: groups)
                    
                    let creationDateFormat = self.parseDuration(creationDateToAdd ?? "")
                                        
                    let post = Picture(user: userToAdd, imageUrl: imageURLToAdd, creationDate: creationDateFormat, groupName: groupNameToAdd, isDeveloped: false, isSelectedByUser: false, picID: key)
                    
//                    let cimageView = CustomImageView()
//                    cimageView.loadImage(urlString: imageURLToAdd)
                    
                    
                    self.posts.append(post)
                    
                    self.posts.sort { (p1, p2) -> Bool in
                        let c1 = Date(timeIntervalSince1970: p1.creationDate)
                        let c2 = Date(timeIntervalSince1970: p2.creationDate)
                        return c1.compare(c2) == .orderedDescending
                    }
                    
                    self.objects.append(PrintableObject(isSelectedByUser: false, post: post))

                    self.objects.sort { (p1, p2) -> Bool in
                        let c1 = Date(timeIntervalSince1970: p1.post.creationDate)
                        let c2 = Date(timeIntervalSince1970: p2.post.creationDate)
                        return c1.compare(c2) == .orderedDescending
                    }
                    self.collectionView.reloadData()
                    self.collectionView?.refreshControl?.endRefreshing()
                    print("Success")
                    
                    self.removeSpinner()

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

    var username: String = ""
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GroupRollCell
        
//        let post = self.posts[indexPath.row]
        
        let pic = self.objects[indexPath.row]
        
        cell.post = pic.post

//        let floatdegrees = Int.random(in: -5...5)
//        cell.rotateImage(degrees: 0)
//
//        cell.groupNameLabel.text = pic.post.groupName
//        cell.usernameLabel.text = "taken by: " + pic.post.user.username
//        cell.dateLabel.text = Date(timeIntervalSince1970: pic.post.creationDate).asString(style: .long)
        
//        cell.groopImage.loadImage(urlString: post.imageUrl)
        let url = URL(string: pic.post.imageUrl)
        cell.photoImageView.kf.setImage(with: url)

//        cell.groopImage.kf.setImage(with: url)

        cell.configureCell(isSelectedByUser: objects[indexPath.row].isSelectedByUser)
                
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        
        let post = self.posts[indexPath.row]

        if isSelected{
            if let cell = collectionView.cellForItem(at: indexPath) as? GroupRollCell {
                                
                if objects[indexPath.row].isSelectedByUser == false {
                    objects[indexPath.row].isSelectedByUser = true
//                    self.posts[indexPath.row].isSelectedByUser = true
                    UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.selectedView.alpha = 1.0
                            cell.selectedBackground.alpha = 0.5
                    })
                }
                else{
//                    self.posts[indexPath.row].isSelectedByUser = false
                    objects[indexPath.row].isSelectedByUser = false
                    UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.selectedView.alpha = 0.0
                            cell.selectedBackground.alpha = 0.0
                    })
                }
            }
        }
        else{
            let pictureVC = PictureController()
            pictureVC.groupNameLabel.text = post.groupName
            
//            pictureVC.groopImage.loadImage(urlString: post.imageUrl)
            
            let url = URL(string: post.imageUrl)
//            pictureVC.groopImage.kf.setImage(with: url)
            pictureVC.photoImageView.kf.setImage(with: url)
            pictureVC.picture = post
            pictureVC.groupId = self.group?.groupid
            
            pictureVC.usernameLabel.text = "taken by: @" + post.user.username
            
            let picDate = Date(timeIntervalSince1970: post.creationDate)
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: NSLocale.current.identifier)
            dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
            pictureVC.dateLabel.text = "date: " + dateFormatter.string(from: picDate)
            
            self.navigationController?.navigationBar.isHidden = false
            self.navigationItem.leftItemsSupplementBackButton = true
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

            self.navigationController?.pushNavBarWithTitle(vc: pictureVC)
            
//            self.navigationItem.setBackImageEmpty()

        }
        
        var boolChecker = false
//        for post in self.posts{
//            if post.isSelectedByUser{
//                boolChecker = true
//            }
//        }
        for object in objects{
            if object.isSelectedByUser{
                boolChecker = true
            }
        }
        
        if boolChecker{
            UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.actualPrintButton.isEnabled = true
                self.actualPrintButton.alpha = 1.0
            })
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        
        if isSelected{
            if let cell = collectionView.cellForItem(at: indexPath) as? GroupRollCell {
                
//                print(indexPath.row, "please")
//                print(objects[indexPath.row].isSelectedByUser, "please")
                
                if objects[indexPath.row].isSelectedByUser == true {
//                    self.posts[indexPath.row].isSelectedByUser = false
                    self.objects[indexPath.row].isSelectedByUser = false
                    UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.selectedView.alpha = 0.0
                            cell.selectedBackground.alpha = 0.0
                    })
                }
                else{
//                    self.posts[indexPath.row].isSelectedByUser = true
                    self.objects[indexPath.row].isSelectedByUser = true
                    UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.selectedView.alpha = 1.0
                            cell.selectedBackground.alpha = 0.5
                    })
                }
            }
         }
         else{
            //nothing
         }
        
        var boolCount = 0
        
//        for post in self.posts{
//            if post.isSelectedByUser == true{
//                boolCount += 1
//            }
//        }
//
        for object in objects{
            if object.isSelectedByUser == true {
                boolCount += 1
            }
        }
        if boolCount == 0 {
            UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.actualPrintButton.isEnabled = false
                self.actualPrintButton.alpha = 0.75
            })
        }
    }
        
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (self.posts.count == 0) {
            self.collectionView.setEmptyMessage("hmm no pics yet. 🤔 ")
        } else {
            self.collectionView.restore()
        }
        
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 23
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 19, left: 14, bottom: 19, right: 14)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width - 2) / 3

        return CGSize(width: width - 25, height: width*1.561 - 40)
    //1.504
    }
    
        
    @objc func handlePrintPhotos(){
        
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.printButton.isHidden = true
            self.friendButton.isHidden = true
            self.actualPrintButton.isHidden = false
            
            self.navigationItem.backBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil

            
            self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.handleCancel)), animated: false)
            
            self.navigationItem.setLeftBarButton(UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(self.handleSelectAll)), animated: false)
                        
            self.navigationItem.title = nil

            self.isSelected = true
            
            print(self.isSelected)

        })
        
    }
    
    @objc func handleSelectAll(){
        
        for object in objects{
            object.isSelectedByUser = true
        }
        
        if objects.count == 0 {
            self.actualPrintButton.isEnabled = false
            self.actualPrintButton.alpha = 0.75
        }
        else{
            self.actualPrintButton.isEnabled = true
            self.actualPrintButton.alpha = 1.0
        }
        
        self.collectionView.reloadData()
        let section = 0
        let item = collectionView.numberOfItems(inSection: section) - 1
        let lastIndexPath = IndexPath(item: item, section: section)
        self.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
        
    }
    
    @objc func handleCancel(){
//        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
        self.printButton.isHidden = false
        self.friendButton.isHidden = false
        self.actualPrintButton.isHidden = true
    
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.backBarButtonItem = nil

        self.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "cameraiconwhite")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.handleCamera)), animated: false)

        self.navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "backbutton"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.handleBack))

        self.isSelected = false

        print(self.isSelected, "please")

        self.navigationItem.title = self.group?.groupname
                
//        for (index, _) in self.posts.enumerated(){
//            self.objects[index].isSelectedByUser = false
//        }
//
        for object in objects{
            object.isSelectedByUser = false
        }

        
        self.collectionView.reloadData()
        
        self.actualPrintButton.isEnabled = false
        self.actualPrintButton.alpha = 0.75


    }
    
    @objc func handleBack(){
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc func handleActualPrintPhotos(){
        
        var printObjectArray = [QuantityObject]()
        
//        for post in self.posts{
//            if post.isSelectedByUser{
//                printObjectArray.append(QuantityObject(quantity: 1))
//            }
//        }
        var count = 0
        for object in objects{
            if object.isSelectedByUser{
                count += 1
                let url = URL(string: object.post.imageUrl)
                let imageView = UIImageView()
                imageView.kf.setImage(with: url)
                
                printObjectArray.append(QuantityObject(quantity: 1, printableObject: object, image: imageView.image ?? UIImage()))
            }
        }
        
        if count == 0 {
            self.presentFailedCheckout()
        }
        else{
            let printQuantityVC =         PrintQuantityController(collectionViewLayout: UICollectionViewFlowLayout())
            
            printQuantityVC.objects = printObjectArray
            
            self.navigationController?.pushNavBarWithTitle(vc: printQuantityVC)
            self.navigationItem.setBackImageEmpty()
        }
    }
    
    func presentFailedCheckout(){
        let alert = UIAlertController(title: "At least 1 photo needs to be printed.", message: "", preferredStyle: .alert)
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
    
    @objc func handleFriends(){
        let friendsVC = FriendsController()
        friendsVC.group = self.group
        self.navigationController?.pushNavBarWithTitle(vc: friendsVC)
        self.navigationItem.setBackImageEmpty()
    }
    
    @objc func handleCamera(){
        print(123)
        
        let cameraController = CameraController()
        cameraController.group = self.group
        
        cameraController.username = username
                                                        
        let navVC = UINavigationController(rootViewController: cameraController)

        navVC.modalPresentationStyle = .fullScreen

        let height: CGFloat = 200 //whatever height you want to add to the existing height
        let bounds = navVC.navigationBar.bounds
        navVC.navigationBar.frame = CGRect(x: 0, y: 0, width: 50, height: bounds.height + height)
        
        navVC.setNavigationBarHidden(true, animated: false)

        self.present(navVC, animated: true, completion: nil)
    }
    
    @objc func updateGroupNameFunc(notification: NSNotification) {
        self.navigationItem.title = notification.userInfo?["groupName"] as? String
          }
    
    
    func layoutViews(){
        
        collectionView.backgroundColor = Theme.backgroundColor
        
        setupNavBar()
        
        self.view.addSubview(printButton)
        printButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 50, paddingRight: 210, width: view.frame.width * 0.482667, height: 66)
        printButton.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 4, spread: 0)
        
        self.view.addSubview(friendButton)
        friendButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 210, paddingBottom: 50, paddingRight: 5, width: view.frame.width * 0.482667, height: 66)
          friendButton.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 4, spread: 0)
        
        self.view.addSubview(actualPrintButton)
        
        self.actualPrintButton.anchor(top: nil, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 50, paddingRight: 5, width: 0, height: 66)
        self.actualPrintButton.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 4, spread: 0)
        self.actualPrintButton.isHidden = true
        
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true

    }
    
    fileprivate func setupNavBar(){
        guard let groupTitle = self.group?.groupname else {return}
        self.navigationItem.title = groupTitle
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "cameraiconwhite")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))

    }

}

extension UIViewController {

    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)

//        present(viewControllerToPresent, animated: true)
        
        present(viewControllerToPresent, animated: true, completion: nil)
    }

    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)

        dismiss(animated: false)
    }
}

extension Date {
  func asString(style: DateFormatter.Style) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = style
    return dateFormatter.string(from: self)
  }
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

var vSpinner : UIView?
 
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = Theme.backgroundColor
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
    
}
