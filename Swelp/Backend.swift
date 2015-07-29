//
//  Backend.swift
//  Swelp
//
//  Created by Mathieu Knecht on 23.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import Parse

func ParsePushAssign () {
    let installation = PFInstallation.currentInstallation()
    installation[Installation.User] = PFUser.currentUser()
    installation.saveInBackgroundWithBlock { (success, error) -> Void in
        if error != nil {println("Push Assign failed")}
    }
}

func ParsePushResign()
{
    let installation = PFInstallation.currentInstallation()
    installation.removeObjectForKey(Installation.User)
    installation.saveInBackgroundWithBlock { (success, error) -> Void in
        if error != nil {println("Push Resign failed")}
    }
}

func SendPushNotification (contact: PFUser!, message: String)
{
    let user = PFUser.currentUser()!
    let text = user[User.FirstName] as! String + ": " + message
    let queryInstallation = PFInstallation.query()!
    queryInstallation.whereKey(Installation.User, equalTo: contact)
    
    let push = PFPush()
    push.setQuery(queryInstallation)
    push.setMessage(text)
    push.sendPushInBackgroundWithBlock { (success, error) -> Void in
        if error != nil {println("Push Notification failed")}
    }
}