//
//  DiscountsController.swift
//  GroopCam
//
//  Created by super on 7/21/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import Firebase

class DiscountsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "discountCell"
    
    var discounts = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        collectionView?.register(DiscountCell.self, forCellWithReuseIdentifier: cellId)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        fetchAllDiscounts()
    }
    
    @objc func handleRefresh() {
        print("Handling refresh..")
        discounts.removeAll()
        fetchAllDiscounts()
        self.collectionView?.refreshControl?.endRefreshing()
    }
    
    fileprivate func fetchAllDiscounts(){
        fetchDiscounts()
        self.collectionView.reloadData()
    }
    
    func fetchDiscounts(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.showSpinner(onView: self.collectionView)
        Database.database().reference().child("discounts").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            guard let discountsDictionary = snapshot.value as? [String: Any] else {
                self.removeSpinner()
                self.collectionView.reloadData()
                return
            }
            self.removeSpinner()
            self.discounts = Array(discountsDictionary.keys)
        })
        
    }
    
    func layoutViews(){
        self.navigationItem.title = "Discount Codes"
        collectionView.backgroundColor = Theme.backgroundColor
        collectionView?.alwaysBounceVertical = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.discounts.count == 0) {
            self.collectionView.setEmptyMessage("No discount codes yet! 😔 Invite friends with referral link.")
        } else {
            self.collectionView.restore()
        }
        return self.discounts.count
//        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 50)/2, height: 45)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DiscountCell

        let discount = self.discounts[indexPath.item]

        cell.label.text = discount
//        cell.label.text = "DJHSYETS"
        
        return cell
    }

}
