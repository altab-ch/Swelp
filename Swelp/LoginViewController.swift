//
//  LoginViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 22.05.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import ParseUI
import Parse
import FBSDKCoreKit
import SwiftyJSON

class LoginViewController: UIViewController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (PFUser.currentUser() != nil){
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //tabVC = storyboard.instantiateViewControllerWithIdentifier("MainTabVC") as? UITabBarController
            //self.presentViewController(tabVC!, animated: true, completion: nil)
            ParsePushAssign()
            self.performSegueWithIdentifier("application_sg", sender: nil)
        }else{
            self.performSegueWithIdentifier("login_sg", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}