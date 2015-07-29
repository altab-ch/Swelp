//
//  SignViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 12.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import ParseUI
import Parse

class SignViewController : PFSignUpViewController, PFSignUpViewControllerDelegate {
 
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.emailAsUsername = true
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        //signUpController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.performSegueWithIdentifier("profile_sg", sender: nil)
        //})
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        println("error")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        println("cancel")
    }
    
}