//
//  Picture.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/6/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import Foundation

struct Picture {
    
    var id: String?

    let user: User
    let imageUrl: String
    let creationDate: TimeInterval
    let groupName: String
    let isDeveloped: Bool
    var isSelectedByUser: Bool

//    init(user: User, dictionary: [String: Any]) {
//        self.user = user
//        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
//
//        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
//        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
//
//        //to be made soon
//        self.isDeveloped = false
//        self.isSelectedByUser = false
//    }
    
    init(user: User, imageUrl: String, creationDate: TimeInterval, groupName: String, isDeveloped: Bool, isSelectedByUser: Bool, picID: String){
        self.user = user
        self.imageUrl = imageUrl
        self.creationDate = creationDate
        self.groupName = groupName
        self.isDeveloped = isDeveloped
        self.isSelectedByUser = isSelectedByUser
        self.id = picID
    }
    
}

struct Pic {
    var id: IndexPath
    var isSelectedForPrinting: Bool
}
