//
//  CameraController.swift
//  GroopCam
//
//  Created by Niranjan Senthilkumar on 1/9/20.
//  Copyright © 2020 NJ. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    
    var group: Group?
        
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "dismissbutton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
//        button.backgroundColor = .blue
        return button
    }()
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)

        //Zubair - Performance optimization
        //NotificationCenter.default.post(name: CameraController.updateGroopFeedNotificationName, object: nil)

    }
    
    let flashButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "flashbutton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleFlash), for: .touchUpInside)
        return button
    }()
    
    @objc func handleFlash(){
        toggleFlash()
    }
    
    let selfieButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "selfieicon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelfie), for: .touchDown)
        return button
    }()
    
    let flashView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.0
        return view
    }()
    
    @objc func handleSelfie(){
        print(123)
        switchCameraTapped(sender: (Any).self)
    }
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "capturePhotoIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    var groupLabel: UILabel = {
        let label = UILabel().setupLabel(ofSize: 20, weight: UIFont.Weight.bold, textColor: .white, text: "slope day bb", textAlignment: .left)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        transitioningDelegate = self
        
        groupLabel.text = group?.groupname ?? ""
        
        setupCaptureSession()
        setupHUD()
    }
    
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationDismisser
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupHUD() {
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 52, paddingRight: 0, width: 87.9, height: 87.9)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                            
        view.addSubview(selfieButton)
        selfieButton.anchor(top: nil, left: groupLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 11, paddingBottom: 0, paddingRight: 0, width: 45, height: 38.38)
        selfieButton.centerYAnchor.constraint(equalTo: capturePhotoButton.centerYAnchor).isActive = true

        
        view.addSubview(flashButton)
        flashButton.anchor(top: nil, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 32, width: 20, height: 40)
        flashButton.centerYAnchor.constraint(equalTo: capturePhotoButton.centerYAnchor).isActive = true
    }
    
    func sepiaFilter(_ input: CIImage, intensity: Double) -> CIImage?
    {
        let sepiaFilter = CIFilter(name:"CISepiaTone")
        sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        return sepiaFilter?.outputImage
    }
    
    @objc func handleCapturePhoto() {
        print("Capturing photo...")
                        
        UIView.animate(withDuration: 0.1, animations: {
            self.flashView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.flashView.alpha = 0.0
            })
        })
            
        if let photoOutputConnection = output.connection(with: AVMediaType.video) {
            photoOutputConnection.videoOrientation = getCurrentOrientation()
        }

        let settings = AVCapturePhotoSettings()
        
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }

        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]

        output.capturePhoto(with: settings, delegate: self)
        
//        NotificationCenter.default.post(name: CameraController.updateGroopFeedNotificationName, object: nil)

    }
    
    func getCurrentOrientation() -> AVCaptureVideoOrientation {
        let currentDevice = UIDevice.current
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        let deviceOrientation = currentDevice.orientation

        var imageOrientation: AVCaptureVideoOrientation!

        if deviceOrientation == .portrait {
            imageOrientation = .portrait
            print("Device: Portrait")
        }else if (deviceOrientation == .landscapeLeft){
            imageOrientation = .landscapeRight
            print("Device: LandscapeLeft")
        }else if (deviceOrientation == .landscapeRight){
            imageOrientation = .landscapeLeft
            print("Device LandscapeRight")
        }else if (deviceOrientation == .portraitUpsideDown){
            imageOrientation = .portraitUpsideDown
            print("Device PortraitUpsideDown")
        }else{
            imageOrientation = .portrait
        }
        
        return imageOrientation
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    var username: String = ""
    
    static let updateGroopFeedNotificationName = NSNotification.Name(rawValue: "UpdateGroopFeed")
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer!)
        
        guard let prevImage = UIImage(data: imageData!) else {return}
        let previm = prevImage.fixOrientation()
        
        let isHorizongal = previm.size.width > previm.size.height
        
        getFormattedImageAndSave(prev: previm, isHorizontal: isHorizongal)
        
        /*
        var prev = UIImage()
        if devicePosition == "front" {
            prev = previm.withHorizontallyFlippedOrientation()
        }
        else{
            prev = previm
        }
        
        guard let cgimage = prev.cgImage else {return}
        let originalCIImage = CIImage(cgImage: cgimage, options: [.applyOrientationProperty:true])

        let sepiaCIImage = originalCIImage

        var previewImage = UIImage()
        previewImage = UIImage(ciImage: sepiaCIImage)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 44, width: view.frame.width, height: view.frame.width * 1.561))
        containerView.backgroundColor = .white
        
        let groopImage = UIImageView()
        containerView.addSubview(groopImage)
        groopImage.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        groopImage.contentMode = .scaleAspectFill
        groopImage.clipsToBounds = true
        groopImage.backgroundColor = .clear
        groopImage.image = previewImage
        
        
        if devicePosition == "front" {
            groopImage.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        
        let groopCamLabel = UILabel().setupLabel(ofSize: 10, weight: UIFont.Weight.regular, textColor: Theme.black, text: "", textAlignment: .right)
        groopCamLabel.sizeToFit()
        containerView.addSubview(groopCamLabel)
        groopCamLabel.anchor(top: groopImage.bottomAnchor, left: nil, bottom: nil, right: groopImage.rightAnchor, paddingTop: -1, paddingLeft: 0, paddingBottom: 0, paddingRight: 1, width: 200, height: 20)
        groopCamLabel.setCharacterSpacing(-0.4)

        containerView.layer.masksToBounds = false
        containerView.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 4, spread: 0)

        
        guard let image = imageWithView(view: containerView) else {return}
        handleSave(image: image, isHorizontal: isHorizongal)
 */
        
    }
    
    func imageWithView(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    var selectedImage: UIImage?
    
    func getFormattedImageAndSave(prev: UIImage, isHorizontal: Bool) {
        //var prev = UIImage()
        let imageView = UIImageView(image: prev)
        imageView.contentMode = .scaleAspectFit

        imageView.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 2, blur: 4, spread: 0)

        //This is where the image size changes from it's original size. Need to handle this thing.
        
        let image = Image(image: imageView.image!, isHorizontal: isHorizontal)

        handleSave(image: image)
        
    }
    func handleSave(image: Image, isHorizontal: Bool = false){
        
        print(123, "please")
        
//        guard let image = selectedImage else { return }
        
        print(256, "please")

        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        print(256, "please")

        guard let groupId = self.group?.groupid else {return}
        
        print(256, "please")
        
        guard let groupName = self.group?.groupname else {return}
        
        print(256, "please")
        
        guard let uploadData = image.image.jpegData(compressionQuality: 0.5) else { return }
        
        let picId = NSUUID().uuidString
        
        print(picId, "please")

        Storage.storage().reference().child("posts").child(picId).putData(uploadData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                print("Failed to upload image", err)
                return
            }
            
            Storage.storage().reference().child("posts").child(picId).downloadURL { (downloadURL, err) in
                if let err = err {
                    print("failed to fetch download url", err)
                    return
                }
                guard let imageUrl = downloadURL?.absoluteString else { return }
                
                print("successfully fetched url")
                
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl, userID: uid, groupID: groupId, groupName: groupName, image: image.image, picId: picId, isHorizontal: image.isHorizontal)
                
            }
        }
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String, userID: String, groupID: String, groupName: String, image: UIImage, picId: String, isHorizontal: Bool) {
        let postImage = image

//        let picId = NSUUID().uuidString
                
        let values = ["imageUrl": imageUrl, "groupname": groupName, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": String(Date().timeIntervalSince1970), "userid": userID, "isHorizontal": isHorizontal] as [String : Any]
        
        let picValues = [picId: values]
        
        Database.database().reference().child("posts").child(groupID).updateChildValues(picValues) { (err, ref) in
            if let err = err {
                print("Failed to save image to DB", err)
                return
            }
            
            print("Successfully saved to post to DB")
        
        }
    Database.database().reference().child("groups").child(groupID).child("lastPicture").setValue(String(Date().timeIntervalSince1970))
    
    }
    
    
    let captureSession = AVCaptureSession()

    let previewLayer = AVCaptureVideoPreviewLayer()
    
    let output = AVCapturePhotoOutput()
    
    fileprivate func setupCaptureSession() {
//        let captureSession = AVCaptureSession()
        
        //1. setup inputs
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let err {
            print("Could not setup camera input:", err)
        }
        
        //2. setup outputs
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        //3. setup output preview
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.session = captureSession
        previewLayer.frame = view.frame
        
        print(view.frame.width, "please")
        previewLayer.frame = CGRect(x: 0, y: 44, width: view.frame.width, height: view.frame.width * 1.64)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        view.addSubview(groupLabel)
        groupLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 65, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 300, height: 24)
        
        view.addSubview(flashView)
        flashView.frame = CGRect(x: 0, y: 44, width: view.frame.width, height: view.frame.width * 1.64)

//        self.navigationController?.view.addSubview(dismissButton)

//        self.navigationItem.titleView?.addSubview(dismissButton)
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 65, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 25, height: 25)
        view.bringSubviewToFront(dismissButton)
        
        captureSession.startRunning()
    }

    var devicePosition: String = "back"
    
    func switchCameraTapped(sender: Any) {
        //Change camera source
        
        let session = captureSession
        
//        if let session = captureSession {
            //Remove existing input
            guard let currentCameraInput: AVCaptureInput = session.inputs.first else {
                return
            }

            //Indicate that some changes will be made to the session
            session.beginConfiguration()
            session.removeInput(currentCameraInput)

            //Get new input
            var newCamera: AVCaptureDevice! = nil
            if let input = currentCameraInput as? AVCaptureDeviceInput {
                if (input.device.position == .back) {
                    newCamera = cameraWithPosition(position: .front)
                    self.flashButton.setImage(UIImage(named: "flashicondisabled"), for: .disabled)
                    self.flashButton.isEnabled = false
                    devicePosition = "front"
                } else {
                    newCamera = cameraWithPosition(position: .back)
                    self.flashButton.isEnabled = true
                    devicePosition = "back"
                }
            }

            //Add input to session
            var err: NSError?
            var newVideoInput: AVCaptureDeviceInput!
            do {
                newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            } catch let err1 as NSError {
                err = err1
                newVideoInput = nil
            }

            if newVideoInput == nil || err != nil {
                print("Error creating capture device input: \(err?.localizedDescription ?? "poopie")")
            } else {
                session.addInput(newVideoInput)
            }

            //Commit all the configuration changes at once
            session.commitConfiguration()
//        }
    }


    
    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }

        return nil
    }
    
    
    
    @objc func toggleFlash() {
        var device : AVCaptureDevice!
        
        
        if #available(iOS 10.0, *) {
            let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDuoCamera], mediaType: AVMediaType.video, position: .unspecified)
            let devices = videoDeviceDiscoverySession.devices
            device = devices.first!

        } else {
            // Fallback on earlier versions
            device = AVCaptureDevice.default(for: AVMediaType.video)
        }
        
        
        
        if ((device as AnyObject).hasMediaType(AVMediaType.video))
        {
            if (device.hasTorch)
            {
                self.captureSession.beginConfiguration()
                //self.objOverlayView.disableCenterCameraBtn();
                if device.isTorchActive == false {
                    self.flashOn(device: device)
                } else {
                    self.flashOff(device: device);
                }
                //self.objOverlayView.enableCenterCameraBtn();
                self.captureSession.commitConfiguration()
            }
        }
    }
    
    func flashOn(device:AVCaptureDevice)
    {
        do{
            if (device.hasTorch)
            {
                try device.lockForConfiguration()
                device.torchMode = .on
                device.flashMode = .on
                device.unlockForConfiguration()
                
//                self.flashButton.setImage(UIImage(named: "flashbuttondisabled")?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }catch{
            //DISABEL FLASH BUTTON HERE IF ERROR
        }
    }
    
    func flashOff(device:AVCaptureDevice)
    {
        do{
            if (device.hasTorch){
                try device.lockForConfiguration()
                device.torchMode = .off
                device.flashMode = .off
                device.unlockForConfiguration()
                
//                self.flashButton.setImage(UIImage(named: "flashbutton")?.withRenderingMode(.alwaysOriginal), for: .normal)

            }
        } catch{
            //DISABEL FLASH BUTTON HERE IF ERROR
        }
    }
    
}

extension UIView {
    func scale(by scale: CGFloat) {
        self.contentScaleFactor = scale
        for subview in self.subviews {
            subview.scale(by: scale)
        }
    }

    func getImage(scale: CGFloat? = nil) -> UIImage {
        let newScale = scale ?? UIScreen.main.scale
        self.scale(by: newScale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale

        let renderer = UIGraphicsImageRenderer(size: self.bounds.size, format: format)

        let image = renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }

        return image
    }
}

public extension UIImage {

    /// Extension to fix orientation of an UIImage without EXIF
    func fixOrientation() -> UIImage {

        guard let cgImage = cgImage else { return self }

        if imageOrientation == .up { return self }

        var transform = CGAffineTransform.identity

        switch imageOrientation {

        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
//            transform = transform.scaledBy(x: -1, y: 1)
            
        case .up, .upMirrored:
            break
        }

        switch imageOrientation {

        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)

        case .up, .down, .left, .right:
            break
        }

        if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {

            ctx.concatenate(transform)

            switch imageOrientation {

            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))

            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }

            if let finalImage = ctx.makeImage() {
                return (UIImage(cgImage: finalImage))
            }
        }

        // something failed -- return original
        return self
    }
}

extension UILabel{
func setCharacterSpacing(_ spacing: CGFloat){
    let attributedStr = NSMutableAttributedString(string: self.text ?? "")
    attributedStr.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSMakeRange(0, attributedStr.length))
    self.attributedText = attributedStr
 }
}
