//
//  Group.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/6/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import Foundation

struct Group {
    
    let groupid: String
    let groupname: String
    var lastPicture: String
    let creationDate: String
    let members: [String: Any]
    let pics: [String]
    
//    init(groupid: String, dictionary: [String: Any]) {
//        self.groupid = groupid
//        self.groupname = dictionary["groupname"] as? String ?? ""
//        self.lastPicture = dictionary["lastPicture"] as? String ?? ""
//        self.creationDate = dictionary["creationDate"] as? String ?? ""
//        self.members = ["": Any()]
//        self.pics = []
//    }
    
    init(groupid: String, groupname: String, lastPicture: String, creationDate: String, members: [String: Any], pics: [String]){
        self.groupid = groupid
        self.groupname = groupname
        self.lastPicture = lastPicture
        self.creationDate = creationDate
        self.members = members
        self.pics = []
    }
}
