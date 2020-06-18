//
//  GroupRollCell.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/7/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit

class PrintableObject {

    var isSelectedByUser: Bool
    var post: Picture
//    var image: UIImage
    
    init(isSelectedByUser: Bool, post: Picture){
        self.isSelectedByUser = isSelectedByUser
        self.post = post
//        self.image = image
    }
    
//    init(isSelectedByUser: Bool) {
//        self.isSelectedByUser = isSelectedByUser
//    }
}

class GroupRollCell: UICollectionViewCell {

    var isSelectedByUser: Bool?
    
    var post: Picture?
    
    var photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        return iv
    }()
    
    var selectedView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "selected")
        iv.backgroundColor = .clear
        return iv
    }()

    var selectedBackground: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .black
        return iv
    }()

    var groopImage: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = Theme.bColor
        return iv
    }()
    
    var groupNameLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 5, weight: UIFont.Weight.regular, textColor: .black, text: "slope day bb", textAlignment: .center)
        label.sizeToFit()
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 5, weight: UIFont.Weight.regular, textColor: .black, text: "December 26th, 2019", textAlignment: .center)
         label.sizeToFit()
         return label
    }()
    
    var usernameLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 5, weight: UIFont.Weight.regular, textColor: .black, text: "taken by: njkumarr", textAlignment: .center)
         label.sizeToFit()
         return label
    }()
    
    var groopCamLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 5, weight: UIFont.Weight.regular, textColor: Theme.lgColor, text: "", textAlignment: .left)
         label.sizeToFit()
         return label
     }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        photoImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        photoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        photoImageView.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 4, spread: 0)
        photoImageView.layer.masksToBounds = false

        photoImageView.layer.shouldRasterize = false
        

//        photoImageView.addSubview(groopImage)
//        groopImage.anchor(top: photoImageView.topAnchor, left: photoImageView.leftAnchor, bottom: photoImageView.bottomAnchor, right: photoImageView.rightAnchor, paddingTop: 9, paddingLeft: 6, paddingBottom: 23, paddingRight: 6, width: 87.88, height: 117.05)
//
//        groopImage.layer.shouldRasterize = false
//
//        photoImageView.addSubview(groupNameLabel)
//        groupNameLabel.anchor(top: groopImage.bottomAnchor, left: groopImage.leftAnchor, bottom: nil, right: groopImage.rightAnchor, paddingTop: 1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 6)
//
//        photoImageView.addSubview(dateLabel)
//        dateLabel.anchor(top: groupNameLabel.bottomAnchor, left: groopImage.leftAnchor, bottom: nil, right: groopImage.rightAnchor, paddingTop: 1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 6)
//
//        photoImageView.addSubview(usernameLabel)
//        usernameLabel.anchor(top: dateLabel.bottomAnchor, left: groopImage.leftAnchor, bottom: nil, right: groopImage.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 6)
//
//        photoImageView.addSubview(groopCamLabel)
//        groopCamLabel.anchor(top: nil, left: groopImage.leftAnchor, bottom: groopImage.topAnchor, right: nil, paddingTop: 0, paddingLeft: -1, paddingBottom: 2, paddingRight: 0, width: 200, height: 6)
//
        photoImageView.addSubview(selectedBackground)
//        addSubview(selectedBackground)
        selectedBackground.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: -1, paddingLeft: 0, paddingBottom: -1, paddingRight: 0, width: 0, height: 0)
        selectedBackground.alpha = 0
        
        photoImageView.addSubview(selectedView)
        selectedView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        selectedView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        selectedView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        selectedView.alpha = 0
        
    }
    
    public func configureCell(isSelectedByUser: Bool) {
        self.isSelectedByUser = isSelectedByUser
        if isSelectedByUser {
            selectedView.alpha = 1.0
            selectedBackground.alpha = 0.5

        }
        else {
            selectedView.alpha = 0.0
            selectedBackground.alpha = 0.0

        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        guard let username = post?.user.username else {return}
        guard let groupname = post?.groupName else {return}
        guard let date = post?.creationDate else {return}
        
        usernameLabel.text = "taken by: " + username
        groupNameLabel.text = groupname
        dateLabel.text = Date(timeIntervalSince1970: date).asString(style: .long)
        
        if isSelectedByUser!{
            selectedView.alpha = 1.0
            selectedBackground.alpha = 0.5

        }
        else{
            selectedView.alpha = 0.0
            selectedBackground.alpha = 0.0

        }
    }
    
    func rotateImage(degrees: Int){
        photoImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double(degrees) * .pi/180));
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

