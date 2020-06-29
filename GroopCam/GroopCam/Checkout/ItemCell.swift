//
//  ItemCell.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/9/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit

class QuantityObject {

    var quantity: Int
    var printableObject: PrintableObject
    var image: UIImage
    var isHorizontal: Bool

    init(quantity: Int, printableObject: PrintableObject, image: UIImage, isHorizontal: Bool) {
        self.quantity = quantity
        self.printableObject = printableObject
        self.image = image
        self.isHorizontal = isHorizontal
    }
}

protocol ItemCellDelegate {
    func didIncrease(for cell: ItemCell)
    func didDecrease(for cell: ItemCell)
}

class ItemCell: UICollectionViewCell {
    
    var delegate: ItemCellDelegate?
        
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        return iv
    }()
    
    let testImage: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .white
        return iv
    }()

//
//    let photoImageView: UIImageView = {
//        let iv = UIImageView()
//        iv.backgroundColor = .yellow
//        return iv
//    }()
    
    var groopImage: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
//        iv.backgroundColor = Theme.bColor
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
        let label = UILabel().setupLabel(ofSize: 5, weight: UIFont.Weight.regular, textColor: Theme.lgColor, text: "groopcam", textAlignment: .left)
        label.sizeToFit()
        return label
     }()
    
    let quantityView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var decreaseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "decreaseicon"), for: .normal)
        button.addTarget(self, action: #selector(handleDecrease), for: .touchUpInside)
        return button
    }()
    
    @objc func handleDecrease(){
        print("Handling decrease in cell...")
        delegate?.didDecrease(for: self)
        
    }
    
    lazy var increaseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "increaseicon"), for: .normal)
        
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gesture:)))
//        button.addGestureRecognizer(longPress)

//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gesture:)))
//        tap.require(toFail: longPress)
//        button.addGestureRecognizer(tap)

        
        button.addTarget(self, action: #selector(handleIncrease), for: .touchUpInside)
        return button
    }()
//    

    @objc func handleIncrease(){
        print("Handling increase in cell...")
        delegate?.didIncrease(for: self)

    }
    
    var quantity: UILabel = {
         let label = UILabel()
         label.font = .systemFont(ofSize: 20, weight: UIFont.Weight.medium)
         label.text = "11"
         label.textColor = .white
         label.textAlignment = .center
         label.sizeToFit()
         return label
     }()
    
    var cellQuantity: QuantityObject? {
        didSet {
            guard let pictureQuantity = cellQuantity?.quantity else {return}
            
            quantity.text = String(pictureQuantity)
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        backgroundColor = Theme.cellColor
        
        addSubview(photoImageView)

        photoImageView.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 4, spread: 0)
        //photoImageView.layer.masksToBounds = false

        addSubview(quantityView)
        quantityView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 26, width: 100, height: 25)
        
        quantityView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                    
        setupQuantityView()
    }
        
    func showVerticalImage() {
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 23, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 150)

        photoImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func showHorizontalImage() {
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        photoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        photoImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        photoImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func setupQuantityView(){
        let stackView = UIStackView(arrangedSubviews: [decreaseButton, quantity, increaseButton])
    
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        stackView.backgroundColor = .magenta
        quantityView.addSubview(stackView)
        stackView.anchor(top: quantityView.topAnchor, left: quantityView.leftAnchor, bottom: quantityView.bottomAnchor, right: quantityView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func rotateImage(degrees: Int){
        photoImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double(degrees) * .pi/180));
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
