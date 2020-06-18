//
//  PreviewPhotoContainer.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/9/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    var selectedView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "selected")
        iv.backgroundColor = .black
        return iv
    }()

    var selectedBackground: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .black
        return iv
    }()
    
    var photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .white
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
        let label = UILabel().setupLabel(ofSize: 16, weight: UIFont.Weight.regular, textColor: .black, text: "slope day bb", textAlignment: .center)
        label.sizeToFit()
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 16, weight: UIFont.Weight.regular, textColor: .black, text: "December 26th, 2019", textAlignment: .center)
         label.sizeToFit()
         return label
    }()
    
    var usernameLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 16, weight: UIFont.Weight.regular, textColor: .black, text: "taken by: ", textAlignment: .center)
         label.sizeToFit()
         return label
    }()
    
    var groopCamLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 16, weight: UIFont.Weight.regular, textColor: Theme.lgColor, text: "groopcam", textAlignment: .left)
         label.sizeToFit()
         return label
     }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
                
        layer.masksToBounds = false

        photoImageView.addSubview(groopImage)
        
        layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 4, spread: 0)
        
        groopImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 37, paddingLeft: 25, paddingBottom: 84, paddingRight: 25, width: 87.88, height: 117.05)
        
        photoImageView.addSubview(groupNameLabel)
        groupNameLabel.anchor(top: groopImage.bottomAnchor, left: groopImage.leftAnchor, bottom: nil, right: groopImage.rightAnchor, paddingTop: 7, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        photoImageView.addSubview(dateLabel)
        dateLabel.anchor(top: groupNameLabel.bottomAnchor, left: groopImage.leftAnchor, bottom: nil, right: groopImage.rightAnchor, paddingTop: 1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        photoImageView.addSubview(usernameLabel)
        usernameLabel.anchor(top: dateLabel.bottomAnchor, left: groopImage.leftAnchor, bottom: nil, right: groopImage.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        photoImageView.addSubview(groopCamLabel)
        groopCamLabel.anchor(top: nil, left: groopImage.leftAnchor, bottom: groopImage.topAnchor, right: nil, paddingTop: 0, paddingLeft: -1, paddingBottom: 2, paddingRight: 0, width: 200, height: 20)
                
        
//        addSubview(cancelButton)
//        cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
//        
//        addSubview(saveButton)
//        saveButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 24, paddingBottom: 24, paddingRight: 0, width: 50, height: 50)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
