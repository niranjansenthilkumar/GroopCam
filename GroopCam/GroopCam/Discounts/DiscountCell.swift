//
//  DiscountCell.swift
//  GroopCam
//
//  Created by super on 7/21/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit

class DiscountCell: UICollectionViewCell {
    
    var label: UILabel = {
        let label = UILabel().setupLabel(ofSize: 18, weight: UIFont.Weight.medium, textColor: .black, text: "discount code", textAlignment: .center)
        return label
    }()
    
    func displayContent(text: String){
        label.text = text
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        setupChannelCell()
        
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
        
    }
    
    func setupChannelCell(){
        backgroundColor = .white
        layer.masksToBounds = false
        layer.cornerRadius = 6
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
