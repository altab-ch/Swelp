//
//  AvatarButton.swift
//  Swelp
//
//  Created by Mathieu Knecht on 22.05.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import Parse
import AFNetworking

class AvatarButton: UIButton, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    internal var label : UILabel = UILabel()
    internal var image : UIImageView = UIImageView()
    var parentViewController : UIViewController?
    internal var picker = UIImagePickerController()
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        self.addTarget(self, action: Selector("btPhotoTouched:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
        label = UILabel(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        label.textColor = UIColor.darkGrayColor()
        label.text = "Choose a photo"
        label.numberOfLines = 2
        label.textAlignment = .Center
        image = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        image.hidden = true
        image.contentMode = .ScaleAspectFill
        image.layer.cornerRadius = self.frame.size.height/2
        self.addSubview(image)
        self.addSubview(label)
        
        picker.delegate = self
        picker.cropMode = .Circular
        
        picker.finalizationBlock = {(UIImagePickerController picker, NSDictionary info)->Void in
            picker.dismissViewControllerAnimated(true, completion: nil)
            let image = info["UIImagePickerControllerEditedImage"] as! UIImage
            self.setPhoto(image)
        }
        
        picker.cancellationBlock = {(UIImagePickerController picker)->Void in
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func btPhotoTouched(sender: AnyObject) {
        
        var sheet : UIActionSheet?
        if (PFUser.currentUser()![User.Id] == nil){
            sheet = UIActionSheet(title: "Photo from", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Selfie", "Library")
        }else{
            sheet = UIActionSheet(title: "Photo from", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Selfie", "Library", "Facebook")
        }
        
        if let vc = self.parentViewController {
            sheet!.showInView(vc.view)
        }
        
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 1: self.showSelfie()
        case 2: self.showLibraryPhotos()
        case 3: self.showFacebookPhotos()
        default: break
        }
    }
    
    func showSelfie(){
        
        if (UIImagePickerController.isCameraDeviceAvailable(.Front)){
            picker.cropMode = .Circular
            picker.sourceType = .Camera
            picker.cameraDevice = .Front
            if let vc = self.parentViewController {
                vc.presentViewController(picker, animated: true, completion: nil)
            }
        }else{
            
        }
        
    }
    
    func showFacebookPhotos(){
        //self.performSegueWithIdentifier("facebook_album_sg", sender: nil)
        let id = PFUser.currentUser()![User.Id] as! Int
        let url = NSURL(string: "http://graph.facebook.com/"+String(id)+"/picture?type=large")
        let operation = AFHTTPRequestOperation(request: NSURLRequest(URL: url!))
        operation.responseSerializer = AFImageResponseSerializer()
        operation.setCompletionBlockWithSuccess({ (operation, result) -> Void in
            let image = result as! UIImage
            self.setPhoto(image)
            }, failure: { (operation, error) -> Void in
                
        })
        NSOperationQueue.mainQueue().addOperation(operation)
    }
    
    func showLibraryPhotos() {
        picker.cropMode = .Circular
        picker.sourceType = .PhotoLibrary
        if let vc = self.parentViewController {
            vc.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func setPhoto (image : UIImage) {
        //self.setImage(image, forState: .Normal)
        self.image.image = image
        self.image.hidden = false
        label.hidden = true
    }
    
    func getPhoto () -> UIImage? {
        return image.image
    }
    
    func removePhoto () {
        label.hidden = false
        self.image.hidden = true
    }
    
}