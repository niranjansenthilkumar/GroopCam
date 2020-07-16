//
//  UpdateFriendsController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/9/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Contacts

class UpdateFriendsController: UITableViewController, UISearchResultsUpdating {
    
    var groupId: String = ""
    var contactsToNotAdd: [String] = []

        
    let cellIdentifier: String = "tableCell"
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutViews()
        
        fetchContacts()
        
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.contactsToNotAdd.removeAll()
        self.groupId = ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.contactsToDisplay.count == 0) {
            self.tableView.setEmptyMessage("All your friends are in this group! 😊")
        } else {
            self.tableView.restore()
        }
        
        if isFiltering {
            return self.filteredContacts.count
        }
        else{
            return self.contactsToDisplay.count
        }
    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.contactsToDisplay[indexPath.row].hasSelected = true
        
//        print(self.contactsToDisplay[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        self.contactsToDisplay[indexPath.row].hasSelected = false
        
//        print(self.contactsToDisplay[indexPath.row])

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CustomTableCell
        
        let contact = contactsToDisplay[indexPath.row]
        
        cell.label.text = contact.firstname + " " + contact.lastname
        cell.usernameLabel.text = "@" + contact.username
        cell.selectionStyle = .none
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        // do some stuff
        filteredContacts = contactsToDisplay.filter { (contact: ContactToDisplay) -> Bool in
            return contact.username.lowercased().contains(find: searchText.lowercased())
    }
        
        tableView.reloadData()
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var filteredContacts: [ContactToDisplay] = []
    
    var favoritableContacts = [FavoritableContact]()
    var contactsToDisplay = [ContactToDisplay]()
    var fullContactsToDisplay = [ContactToDisplay]()
    
    private func fetchContacts(){
        print("Attempting to fetch contacts today")
        
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed to request access:", err)
                return
            }
            
            if granted {
                print("Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do{
                    
//                    var favoritableContacts = [FavoritableContact]()
                    
                    try store.enumerateContacts(with: request) { (contact, stopPointerIfYouWantToStopEnumerating) in
                        
//                        print(contact.givenName + " " + contact.familyName)
                        
                        var ogphoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
                        
                        var phoneNumber = ogphoneNumber.components(separatedBy:CharacterSet.decimalDigits.inverted).joined()
                                                
                        if phoneNumber.count == 10 {
//                            print("+1" + phoneNumber)
                            phoneNumber = "+1" + phoneNumber
                        }
                        else if phoneNumber.count == 11 {
//                            print("+" + phoneNumber)
                            phoneNumber = "+" + phoneNumber
                        }
                        else{
                            phoneNumber = "+" + phoneNumber
                        }
                        
                        var boolChecker = true
                        for phonecontact in self.contactsToNotAdd{
                            if phoneNumber == phonecontact{
                                boolChecker = false
                            }
                        }
                        
                        if boolChecker{
                            self.favoritableContacts.append(FavoritableContact(firstname: contact.givenName, lastname: contact.familyName, phonenumber: phoneNumber, hasSelected: false))
                        }
                        

                        
                        
                        
//                        favoritableContacts.append(FavoritableContact(name: contact.givenName + " " + contact.familyName, hasSelected: false))
                    }
                    

                } catch let err{
                    print("Failed to enumerate contacts:", err)
                }
                
            } else {
                print("Access denied...")
            }
            
            print(self.favoritableContacts.count, "please")
            
            for contact in self.favoritableContacts {
                Database.database().reference().child("contacts").observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.hasChild(contact.phonenumber){
                        print("phonenumber exists")
                        
                    Database.database().reference().child("contacts").child(contact.phonenumber).observeSingleEvent(of: .value) { (snapshot) in
                        if let value = snapshot.value as? [String: Any] {
                            guard let uid = value["uid"] else {return}
                            guard let username = value["username"] else {return}
                            
//                            print(uid, "please")
//                            print(username, "please")
                            let uidToAdd = uid as? String ?? ""
                            let usernameToAdd = username as? String ?? ""
                            //dont add current user
                            if uidToAdd != Auth.auth().currentUser?.uid {
                                let contact = ContactToDisplay(firstname: contact.firstname, lastname: contact.lastname, phonenumber: contact.phonenumber, hasSelected: false, uid: uidToAdd, username: usernameToAdd)
                                
                                self.contactsToDisplay.append(contact)
                                self.tableView.reloadData()
                            }
                            //fullcontacts
                            let contact = ContactToDisplay(firstname: contact.firstname, lastname: contact.lastname, phonenumber: contact.phonenumber, hasSelected: false, uid: uidToAdd, username: usernameToAdd)
                            self.fullContactsToDisplay.append(contact)
                            }
                        }
                        
                    }
                }
            }
        }
        
    }
    
    func presentGroupAddError(){
            let alert = UIAlertController(title: "Please add at least 1 friend.", message: "", preferredStyle: .alert)
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
    
    static let updateAddFriendNotificationName = NSNotification.Name(rawValue: "UpdateAddFriendFeed")

    
    @objc func handleAddFriends(){
        
        let groupId = self.groupId
        

        var members: [String? : Bool] = [:]

        for contact in self.contactsToDisplay {
            if contact.hasSelected == true {
                members[contact.uid] = true
            }
        }
        
        if members.count == 0 {
            self.presentGroupAddError()
        }
            
        else{
    
            Database.database().reference().child("members").child(groupId).updateChildValues(members) { (err, ref) in
                    if let err = err {
                        print("Failed to save group members into db:", err)
                        return
                    }
                    print("Successfully saved group members to db")
            }
            
            
            var uidsToUpdate: [String] = []
            
            for contact in self.contactsToDisplay {
                if contact.hasSelected == true{
                    uidsToUpdate.append(contact.uid)
                }
            }

            let userGroups = [groupId: true]


            for currentuid in uidsToUpdate {
            Database.database().reference().child("users").child(currentuid).child("groups").updateChildValues(userGroups) { (err, ref) in
                    if let err = err {
                        print("Failed to append group to user", err)
                    }
                    else{
                        print("Successfully appended group to user")
                    }
                }
            }
            

            self.navigationController?.popToRootViewController(animated: true)
//            self.navigationController?.popViewController(animated: true)
            
            NotificationCenter.default.post(name: UpdateFriendsController.updateAddFriendNotificationName, object: nil)

        }

    }

    func layoutViews(){
        setupNavBar()
        setupTableView()
        setupSearchBar()
    }
    
    fileprivate func setupNavBar(){
        self.navigationItem.title = "Add Friends"
    
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "addfriendsicon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddFriends))
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    
    fileprivate func setupTableView(){
        
        self.tableView.backgroundView?.backgroundColor = Theme.backgroundColor
        self.tableView.tableHeaderView = searchController.searchBar
        tableView.register(CustomTableCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.allowsMultipleSelection = true
        tableView.backgroundColor = Theme.backgroundColor
        self.tableView.backgroundView = UIView()
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func setupSearchBar(){

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.searchController.searchBar.isTranslucent = false
        self.searchController.searchBar.backgroundImage = UIImage()
        self.searchController.searchBar.barTintColor = Theme.backgroundColor
        self.searchController.searchBar.tintColor = UIColor.white
                
        searchController.searchBar.barTintColor = Theme.backgroundColor
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.backgroundColor = Theme.whiteopacity
            searchController.searchBar.searchTextField.placeholder = "Search by username"
            searchController.searchBar.searchTextField.textColor = Theme.lgColor

        } else {
            // Fallback on earlier versions
        }
        

        if let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField,
            let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
                //Magnifying glass
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = Theme.lgColor
        }
        
        searchController.searchBar.tintColor = .black
    }
    
}
