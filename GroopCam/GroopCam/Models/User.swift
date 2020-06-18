//
//  User.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/6/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let username: String
    let phonenumber: String
    let groups: [String: Any]
    
//    init(uid: String, dictionary: [String: Any]) {
//        self.uid = uid
//        self.username = dictionary["username"] as? String ?? ""
//        self.phonenumber = dictionary["phonenumber"] as? String ?? ""
//        self.groups = dictionary["groups"] as? [String : Any] ?? ["" : 0]
//    }
    
    init(uid: String, username: String, phonenumber: String, groups: [String: Any]){
        self.uid = uid
        self.username = username
        self.phonenumber = phonenumber
        self.groups = groups
    }
}

struct FavoritableContact {
    let firstname: String
    let lastname: String
    let phonenumber: String
    var hasSelected: Bool
}

struct ContactToDisplay {
    let firstname: String
    let lastname: String
    let phonenumber: String
    var hasSelected: Bool
    let uid: String
    let username: String
}

struct FriendToDisplay {
    let phonenumber: String
    let username: String
}
