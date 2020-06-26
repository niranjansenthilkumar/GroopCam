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
    var imageWidth: Double
    var imageHeight: Double
    var isHorizontal: Bool
    
    init(user: User, imageUrl: String, creationDate: TimeInterval, groupName: String, isDeveloped: Bool, isSelectedByUser: Bool, picID: String, imageWidth: Double, imageHeight: Double, isHorizontal: Bool){
        self.user = user
        self.imageUrl = imageUrl
        self.creationDate = creationDate
        self.groupName = groupName
        self.isDeveloped = isDeveloped
        self.isSelectedByUser = isSelectedByUser
        self.id = picID
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.isHorizontal = isHorizontal
    }
    
}

struct Pic {
    var id: IndexPath
    var isSelectedForPrinting: Bool
}
