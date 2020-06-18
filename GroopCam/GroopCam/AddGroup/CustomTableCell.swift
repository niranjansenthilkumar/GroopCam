//
//  CustomTableCell.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/6/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit

class CustomTableCell: UITableViewCell {
    
    var label: UILabel = {
        let label = UILabel().setupLabel(ofSize: 13, weight: UIFont.Weight.bold, textColor: .black, text: "Niranjan Senthilkumar", textAlignment: .left)
        return label
    }()
    
    var usernameLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 13, weight: UIFont.Weight.regular, textColor: Theme.lgColor, text: "@njkumar", textAlignment: .left)
        return label
    }()
    
    var selectedLabel: UIImageView = {
        let label = UIImageView()
        label.image = UIImage(named: "notselected")
        return label
    }()
    
    func displayContent(text: String){
        label.text = text
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
        usernameLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 13, paddingBottom: 3, paddingRight: 0, width: 200, height: 25)

        addSubview(selectedLabel)
        selectedLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 8, paddingRight: 10, width: 25, height: 25)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected{
            selectedLabel.image = UIImage(named: "selected")
        }
        else{
            selectedLabel.image = UIImage(named: "notselected")
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
