//
//  ReferralViewController.swift
//  GroopCam
//
//  Created by super on 7/16/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MessageUI

class ReferralViewController: UIViewController {
    
    let inviteFirendsButton: UIButton = {
        let button = UIButton().setupButton(backgroundColor: Theme.buttonColor, title: "Invites Friends", titleColor: .white, ofSize: 25, weight: UIFont.Weight.medium, cornerRadius: 15)
        button.addTarget(self, action: #selector(handleInvitesFriends), for: .touchUpInside)
        return button
    }()
    
    let cameraLensImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cameralensicon")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let topLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 30, weight: UIFont.Weight.medium, textColor: .white, text: "Invite Friends.\nGet 5 Free Prints.", textAlignment: .center)
        label.numberOfLines = 2
        return label
    }()
    
    let centerLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 16, weight: UIFont.Weight.medium, textColor: .white, text: "Invite friends to Groopcam. Once they\nsign up, you’ll both get 5 free prints, just\npay shipping.", textAlignment: .center)
        label.numberOfLines = 3
        return label
    }()
    
    
    let clipboardButton: UIButton = {
        let button = UIButton().setupButton(backgroundColor:.clear, title: "Copy to Clipboard", titleColor: .white, ofSize: 18, weight: UIFont.Weight.medium, cornerRadius: 0)
        button.addTarget(self, action: #selector(handleCopyClipboard), for: .touchUpInside)
        return button
    }()
    
    var invitationUrl : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutViews()
        makeReferralLink()
    }
    
    @objc func handleInvitesFriends() {
        if !MFMessageComposeViewController.canSendText() {
            self.presentMessageServiceError()
            return
        }
        
        self.sendText()
    }
    
    @objc func handleCopyClipboard() {
        clipboardButton.setTitle("Copied!", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.clipboardButton.setTitle("Copy to Clipboard", for: .normal)
        })
    }
    
    @objc func toggleDiscounts() {
        let discountVC = DiscountsController(collectionViewLayout: UICollectionViewFlowLayout())
        self.navigationController?.pushNavBarWithTitle(vc: discountVC)
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func sendText() {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Checkout this app GroopCam! I referred you so you can get 5 free prints. Claim this now: \(self.invitationUrl!)"
            controller.recipients = []
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func presentMessageServiceError(){
        let alert = UIAlertController(title: "Message services are not available.", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
            switch action.style{
                case .default:
                      print("default")

                case .cancel:
                      print("cancel")

                case .destructive:
                      print("destructive")

                @unknown default:
                  fatalError()
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func layoutViews(){
        self.view.backgroundColor = Theme.backgroundColor
        
        let discountsButton = UIBarButtonItem(title: "Discounts", style: .plain, target: self, action: #selector(toggleDiscounts))
        self.navigationItem.rightBarButtonItem = discountsButton
        
        self.view.addSubview(cameraLensImageView)
        cameraLensImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cameraLensImageView.centerYAnchor.constraint(lessThanOrEqualTo: self.view.centerYAnchor, constant: -60).isActive = true
        
        cameraLensImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 250, height: 250)
       
        self.view.addSubview(topLabel)
        topLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        topLabel.anchor(top: nil, left: nil, bottom: self.cameraLensImageView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 0, height: 0)
        
        self.view.addSubview(centerLabel)
        centerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        centerLabel.anchor(top: self.cameraLensImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.view.addSubview(inviteFirendsButton)
        inviteFirendsButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        inviteFirendsButton.anchor(top: centerLabel.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 30, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 66)
        
        self.view.addSubview(clipboardButton)
        clipboardButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        clipboardButton.anchor(top: self.inviteFirendsButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

    }
    
    func makeReferralLink() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let link = URL(string: "https://groopcam.com/?invitedby=\(uid)")
        let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://groopcam.page.link")!
        referralLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "NJ.GroopCam")
        referralLink.iOSParameters?.minimumAppVersion = "1.07"
        referralLink.iOSParameters?.appStoreID = "1496034307"

        referralLink.shorten { (shortURL, warnings, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.invitationUrl = shortURL?.absoluteString
//            self.clipboardButton.setTitle("\(self.invitationUrl!)", for: .normal)
        }
        
    }

}

extension ReferralViewController : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
