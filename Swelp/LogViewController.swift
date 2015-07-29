//
//  LogViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 12.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import ParseUI
import Parse
import FBSDKCoreKit
import SwiftyJSON

class LogViewController: PFLogInViewController, PFLogInViewControllerDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("dismiss"), name: "DismissLogin", object: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signController = storyboard.instantiateViewControllerWithIdentifier("SignInVC") as? PFSignUpViewController
        self.delegate = self
        self.signUpController = signController
        
        self.fields = (PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.Facebook
            | PFLogInFields.SignUpButton | PFLogInFields.PasswordForgotten)
        
        self.logInView?.logo = nil
        
        /*let image = UIImage(named: "back")!
        
        let size = self.view.frame.size
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        logInController.logInView?.backgroundColor = UIColor(patternImage: scaledImage)*/
        self.facebookPermissions = ["public_profile", "user_photos", "user_friends", "email"]

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logInView?.usernameField?.placeholder = "Email"
    }
    
    func dismiss(){
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        
        //logInController.dismissViewControllerAnimated(false, completion: { () -> Void in
        if (user.isNew){
            self.requestFacebook(user)
        }else{
            //self.requestFacebook(user)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        //})
        
        
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        println("error")
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        println("cancel")
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //currentVC = segue.destinationViewController as? UIViewController
    }
    
    
    func requestFacebook(user: PFUser) {
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            let request = FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error: NSError!) -> Void in
                if (error == nil){
                    println(result)
                    self.processFacebook(user, data: JSON(result))
                    self.performSegueWithIdentifier("profile_sg", sender: nil)
                }
            })
        }
        
        
    }
    
    func processFacebook (user: PFUser, data:JSON){
        user[User.FirstName] = data["first_name"].stringValue
        user[User.LastName] = data["last_name"].stringValue
        user[User.Email] = data["email"].stringValue
        user[User.Id] = data["id"].intValue
        user[User.Locale] = data["locale"].stringValue
        user[User.Gender] = data["gender"].stringValue
        
        user.saveInBackground()
        
    }
    
}