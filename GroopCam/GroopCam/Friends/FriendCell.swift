//
//  FriendCell.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/9/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    
    var label: UILabel = {
        let label = UILabel().setupLabel(ofSize: 14, weight: UIFont.Weight.bold, textColor: .black, text: "@njkumarr", textAlignment: .left)
        return label
    }()
    
    var usernameLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 11, weight: UIFont.Weight.regular, textColor: Theme.lgColor, text: "+12037224638", textAlignment: .left)
        return label
    }()
    
    func displayContent(text: String){
//        label.text = text
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
        
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 13, paddingBottom: 0, paddingRight: 0, width: 200, height: 25)
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 13, paddingBottom: 2, paddingRight: 0, width: 200, height: 25)
//        self.usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
