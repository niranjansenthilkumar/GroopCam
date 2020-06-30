//
//  PictureController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/8/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MessageUI

import Photos

class PictureController: UIViewController, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate {
    
    var picture: Picture?
    var groupId: String?
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        return iv
    }()
    
    var buttonSelection: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        return button
    }()
    
    var groopImage: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = Theme.bColor
        return iv
    }()
    
    var groupNameLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 14, weight: UIFont.Weight.medium, textColor: .black, text: "slope day bb", textAlignment: .center)
        label.sizeToFit()
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 14, weight: UIFont.Weight.medium, textColor: .black, text: "December 26th, 2019", textAlignment: .center)
        label.sizeToFit()
        return label
     }()
    
    var usernameLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 14, weight: UIFont.Weight.medium, textColor: .black, text: "taken by: njkumarr", textAlignment: .center)
        label.sizeToFit()
        return label
    }()
    
    var groopCamLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 14, weight: UIFont.Weight.medium, textColor: Theme.lgColor, text: "", textAlignment: .left)
        label.sizeToFit()
        return label
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.backgroundColor
        
        let uploadButton = UIBarButtonItem(image: UIImage(named: "uploadicon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(shareAction))
        
        let deleteButton = UIBarButtonItem(image: UIImage(named: "deleteicon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(deleteAction))
        
        self.navigationItem.rightBarButtonItems = [deleteButton, uploadButton]
                
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 24, paddingBottom: 182, paddingRight: 24, width: 0, height: 1.5*view.frame.width - 48)
        
        photoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        

        photoImageView.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 4, spread: 0)
        photoImageView.layer.masksToBounds = false

        photoImageView.layer.shouldRasterize = false

//        photoImageView.addSubview(groopImage)
//        groopImage.anchor(top: photoImageView.topAnchor, left: photoImageView.leftAnchor, bottom: photoImageView.bottomAnchor, right: photoImageView.rightAnchor, paddingTop: 32, paddingLeft: 20, paddingBottom: 72, paddingRight: 20, width: 0, height: 0)
//
//        photoImageView.addSubview(groupNameLabel)
//        groupNameLabel.anchor(top: groopImage.bottomAnchor, left: groopImage.leftAnchor, bottom: nil, right: groopImage.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 16)
//
//        photoImageView.addSubview(dateLabel)
//        dateLabel.anchor(top: groupNameLabel.bottomAnchor, left: groopImage.leftAnchor, bottom: nil, right: groopImage.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 16)
//
//        photoImageView.addSubview(usernameLabel)
//        usernameLabel.anchor(top: dateLabel.bottomAnchor, left: groopImage.leftAnchor, bottom: nil, right: groopImage.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 16)
//
//        photoImageView.addSubview(groopCamLabel)
//        groopCamLabel.anchor(top: nil, left: groopImage.leftAnchor, bottom: groopImage.topAnchor, right: nil, paddingTop: 0, paddingLeft: -1, paddingBottom: 4, paddingRight: 0, width: 300, height: 16)

    }
    
    static let updatePictureNotificationName = NSNotification.Name(rawValue: "UpdatePictureFeed")
    
    @objc func deleteAction(){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
                   print("User click Delete button")
                   
                   guard let pictureId = self.picture?.id else {return}
                   
                   let storageRef = Storage.storage().reference().child("posts").child(pictureId)
                   
                   storageRef.delete { (err) in
                       if let err = err {
                           print("failed to delete image")
                           
                       }
                       
                       guard let groupId = self.groupId else {return}
                       
                       Database.database().reference().child("posts").child(groupId).child(pictureId).removeValue()

                       print("successfully deleted image")
                       
                       NotificationCenter.default.post(name: PictureController.updatePictureNotificationName, object: nil)

                       
                       self.navigationController?.popViewController(animated: true)
                   }
                   
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
                   print("User click Dismiss button")
               
           
        }))

               self.present(alert, animated: true, completion: {
                   print("completion block")
        })
        
    }
    
    @objc func shareAction(){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Share", style: .default , handler:{ (UIAlertAction)in
                   print("User click Share button")
                   
                   if !MFMessageComposeViewController.canSendText() {
                       self.presentMessageServiceError()
                       return
                   }
                   
                   let textComposer = MFMessageComposeViewController()
                   textComposer.messageComposeDelegate = self
                   textComposer.body = "Check out this pic I took on GroopCam 📸 https://apple.co/2S052xI"

                   if MFMessageComposeViewController.canSendAttachments() {
                       let imageData = self.photoImageView.asImage().jpegData(compressionQuality: 0.5)
                       textComposer.addAttachmentData(imageData!, typeIdentifier: "image/jpg", filename: "photo.jpg")
                   }
                   
                   self.present(textComposer, animated: true)

                   
        }))
                        
        alert.addAction(UIAlertAction(title: "Add to Camera Roll", style: .default , handler:{ (UIAlertAction)in
                   print("User click Add to Cam Roll button")
            
                   self.savePhotoToLibrary()
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
                   print("User click Dismiss button")
        
        }))

        self.present(alert, animated: true, completion: {
                   print("completion block")
        })
        
    }
    
    func savePhotoToLibrary() {
        
        guard let pictureId = self.picture?.id else {return}
           
          let storageRef = Storage.storage().reference().child("posts").child(pictureId)
               
          storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                       
          if let error = error {
             print("failed to download image")
          }
                       
          else {
                let pic = UIImage(data: data!)
            UIImageWriteToSavedPhotosAlbum(pic!, self, #selector(self.photoSaver), nil)
          }
        }
    }

    @objc func photoSaver(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
            if let error = error {
    
                let ac = UIAlertController(title: "Error", message: "Your picture could not be saved. \nClick Settings to change your settings and give GroopCam access to your photo library.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in

                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }

                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)")
                        })
                    }
                }
                
                ac.addAction(settingsAction)
                present(ac, animated: true)
                
            } else {
                let ac = UIAlertController(title: "Saved", message: "Your picture has been saved to your photo library.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
        
    
    func sendText() {
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = "Come join me on GroopCam, a social camera roll app 📸😎 https://apple.co/2S052xI"
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

            }}))
            self.present(alert, animated: true, completion: nil)
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            //... handle sms screen actions
            self.dismiss(animated: true, completion: nil)
    }
    
}


