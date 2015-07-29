//
//  SigninViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 23.05.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import Parse
//import AFNetworking
import ParseUI

class SigninViewController: PFSignUpViewController, PFSignUpViewControllerDelegate, UINavigationControllerDelegate {
    
    //var picker = UIImagePickerController()
    var btAvatar: AvatarButton?
    var activity = UIActivityIndicatorView(frame: CGRectMake(10, 5, 20, 20))
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.fields = (PFSignUpFields.UsernameAndPassword | PFSignUpFields.SignUpButton
            | PFSignUpFields.Additional)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*picker.delegate = self
        picker.cropMode = .Circular
        
        picker.finalizationBlock = {(UIImagePickerController picker, NSDictionary info)->Void in
            picker.dismissViewControllerAnimated(true, completion: nil)
            let image = info["UIImagePickerControllerEditedImage"] as! UIImage
            self.btAvatar!.setPhoto(image)
        }
        
        picker.cancellationBlock = {(UIImagePickerController picker)->Void in
            picker.dismissViewControllerAnimated(true, completion: nil)
        }*/
        
        
        self.signUpView?.logo = UIView()
        self.signUpView?.passwordField?.secureTextEntry = false
        self.signUpView?.usernameField?.placeholder = "First name"
        self.signUpView?.passwordField?.placeholder = "Last name"
        self.signUpView?.additionalField?.placeholder = "Zip code"
        self.signUpView?.signUpButton?.setTitle("Create account", forState: UIControlState.Normal)
        self.signUpView?.signUpButton?.removeTarget(self, action: Selector("_signUpAction"), forControlEvents: UIControlEvents.TouchUpInside)
        self.signUpView?.signUpButton?.addTarget(self, action: Selector("createAccount"), forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func createAccount(){
        
        
        if (count(signUpView!.usernameField!.text)<2){
            let alert = UIAlertView(title: "First name error", message: "First name must be at leat 2 characters", delegate: nil, cancelButtonTitle: "Cancel")
            alert.show()
        }else if(count(signUpView!.passwordField!.text)<2){
            let alert = UIAlertView(title: "Last name error", message: "Last name must be at leat 2 characters", delegate: nil, cancelButtonTitle: "Cancel")
            alert.show()
        }else if (btAvatar?.getPhoto() == nil){
            let alert = UIAlertView(title: "Photo error", message: "Add a photo", delegate: nil, cancelButtonTitle: "Cancel")
            alert.show()
        }else{
            self.isLoading(true)
            signUpView!.signUpButton!.addSubview(activity)
            activity.startAnimating()
            
            var user = PFUser.currentUser()!
            
            let imageData = UIImageJPEGRepresentation(btAvatar!.getPhoto(),1)
            let imageFile = PFFile(name: "avatar.png", data: imageData)
            imageFile.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                
                if (error != nil){
                    let alert = UIAlertView(title: "Network error", message: "Couldn't upload photo", delegate: nil, cancelButtonTitle: "Cancel")
                    alert.show()
                    self.activity.stopAnimating()
                    self.activity.removeFromSuperview()
                    self.isLoading(false)
                }else{
                    user[User.FirstName] = self.signUpView!.usernameField!.text
                    user[User.LastName] = self.signUpView!.passwordField!.text
                    user[User.npa] = self.signUpView!.additionalField!.text
                    user[User.AvatarFile] = imageFile
                    user.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if (error != nil){
                            let alert = UIAlertView(title: "Network error", message: "Couldn't upload profile", delegate: nil, cancelButtonTitle: "Cancel")
                            alert.show()
                            self.isLoading(false)
                        }else{
                            NSNotificationCenter.defaultCenter().postNotificationName("DismissLogin", object: nil)
                        }
                        self.activity.stopAnimating()
                        self.activity.removeFromSuperview()
                    })
                }
            })
        }
    }
    
    func isLoading (isLoading:Bool){
        self.signUpView?.usernameField?.enabled = !isLoading
        self.signUpView?.passwordField?.enabled = !isLoading
        self.signUpView?.additionalField?.enabled = !isLoading
        self.signUpView?.signUpButton?.enabled = !isLoading
        self.btAvatar?.enabled = !isLoading
    }
    
    /*func btPhotoTouched(sender: AnyObject) {
        
        var sheet : UIActionSheet?
        if (PFUser.currentUser()![User.Id] == nil){
            sheet = UIActionSheet(title: "Photo from", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Selfie", "Library")
        }else{
            sheet = UIActionSheet(title: "Photo from", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Selfie", "Library", "Facebook")
        }
        
        sheet!.showInView(self.view)
    }*/
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        if (btAvatar == nil){
            let height = signUpView!.usernameField!.frame.origin.y - 50
            self.btAvatar = AvatarButton(frame: CGRectMake((signUpView!.bounds.size.width-height)/2, 30, height, height))
            self.btAvatar!.parentViewController = self
            //self.btAvatar?.addTarget(self, action: Selector("btPhotoTouched:"), forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(self.btAvatar!)
        }
        
    }
    
    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == self.signUpView!.usernameField) {
            signUpView!.passwordField!.becomeFirstResponder()
            return true
        }
        
        if (textField == signUpView!.passwordField) {
            if ((signUpView!.emailField) != nil)
            {
                signUpView!.emailField!.becomeFirstResponder()
                return true
            } else if ((signUpView!.additionalField) != nil) {
                signUpView!.additionalField!.becomeFirstResponder()
                return true
            }
        }
        
        if (textField == signUpView!.emailField) {
            if ((signUpView!.additionalField) != nil) {
                signUpView!.additionalField!.becomeFirstResponder()
                return true
            }
        }
        
        
        
        return true
        
    }
    
    /*func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
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
            presentViewController(picker, animated: true, completion: nil)
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
            self.btAvatar!.setPhoto(image)
        }, failure: { (operation, error) -> Void in
            
        })
        NSOperationQueue.mainQueue().addOperation(operation)
    }
    
    func showLibraryPhotos() {
        picker.cropMode = .Circular
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }*/
}