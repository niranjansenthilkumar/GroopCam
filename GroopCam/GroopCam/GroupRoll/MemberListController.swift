//
//  MemberListController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/9/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit

class FriendsController: UITableViewController {
    
    let cellIdentifier: String = "tableCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupNavBar()
        
        setupTableView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendCell

        cell.selectionStyle = .none
        
        return cell
    }
    
    
    fileprivate func setupNavBar(){
        self.navigationItem.title = "Friends"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "creategroup")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCreateGroup))

    }
    
    
    fileprivate func setupTableView(){
        
        self.tableView.backgroundView?.backgroundColor = Theme.backgroundColor

            
        tableView.register(FriendCell.self, forCellReuseIdentifier: cellIdentifier)
        

        tableView.allowsMultipleSelection = true
        
        tableView.backgroundColor = Theme.backgroundColor
        self.tableView.backgroundView = UIView()
    }
    
    @objc func handleCreateGroup(){
        print(123)
    }
}
