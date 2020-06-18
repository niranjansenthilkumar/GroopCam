//
//  GroupCell.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/6/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit

class GroupCell: UICollectionViewCell {
    
    var group: Group?
    
    var label: UILabel = {
        let label = UILabel().setupLabel(ofSize: 20, weight: UIFont.Weight.medium, textColor: .black, text: "slopeday bb", textAlignment: .left)
        return label
    }()
    
    let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(Theme.verylgColor, for: .normal)
        return button
    }()
    
    var recentLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 12, weight: UIFont.Weight.regular, textColor: Theme.lessgColor, text: "1 min ago by njkumar", textAlignment: .left)
        return label
    }()
    
    let cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "camerabutton"), for: UIControl.State.normal)
        return button
    }()
    
    let groupAvatar: UIImageView = {
        let label = UIImageView()
        label.image = UIImage(named: "groupnumberred")
        return label
    }()
    
    var groupNumberLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 15, weight: UIFont.Weight.medium, textColor: Theme.buttonColor, text: "11", textAlignment: .right)
        return label
    }()
    
    func displayContent(text: String, caption: String, amount: String){
        label.text = text
        recentLabel.text = caption
        groupNumberLabel.text = amount
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        setupChannelCell()
        
        addSubview(cameraButton)
        cameraButton.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 6, paddingBottom: 8, paddingRight: 0, width: 48, height: 48)
        cameraButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(groupAvatar)
        groupAvatar.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 28, width: 28, height: 23)
        groupAvatar.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(groupNumberLabel)
        groupNumberLabel.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 15, height: 18)
        groupNumberLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(label)
        label.anchor(top: cameraButton.topAnchor, left: cameraButton.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 200, height: 24)
        
        addSubview(recentLabel)
        recentLabel.anchor(top: nil, left: cameraButton.rightAnchor, bottom: cameraButton.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 5, paddingRight: 0, width: 200, height: 14)
        
        addSubview(optionsButton)
        optionsButton.anchor(top: groupNumberLabel.bottomAnchor, left: nil, bottom: nil, right: groupNumberLabel.rightAnchor, paddingTop: -3, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 0)
        
    }
    
    func setupChannelCell(){
        
        backgroundColor = .white
        layer.masksToBounds = false
        layer.cornerRadius = 6

//        layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 4, spread: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
