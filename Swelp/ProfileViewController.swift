//
//  ProfileViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 12.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import Parse


class ProfileViewController: UITableViewController {
    
    var skillz = [PFObject]()
    var user : PFUser?
    var isEditable : Bool = false
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateSkills"), name: "ProfileUpdateSkills", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (user == nil){
            user = PFUser.currentUser()!
            self.isEditable = true
        }
        self.updateSkills()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 :
            if (isEditable){
                return 1
            }else{
                return 3
            }
            
        case 1 :
            if (isEditable){
                return skillz.count+1
            }
            return skillz.count

        case 2 : return 1
            
        default : return 0
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if !isEditable {return 2}
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0: return "INFO"
            case 1: return "SKILLS"
            case 2: return "PARAMETERS"
            default: return ""
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0 :
            if indexPath.row != 0 {return 56}
            return 131
        case 1 : return 56
        case 2 : return 100
        default : return 50
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1 && indexPath.row == skillz.count) {
            performSegueWithIdentifier("category_sg", sender: nil)
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.section {
        case 0 :
            
            switch indexPath.row {
            case 0:
                let cellProfile = tableView.dequeueReusableCellWithIdentifier("profile_info", forIndexPath: indexPath) as! ProfileInfoCell
                var btAvatar = cellProfile.contentView.viewWithTag(1) as! AvatarButton
                btAvatar.parentViewController = self
                cellProfile.setUser(self.user!, editable: self.isEditable)
                cell = cellProfile
                /*if !isEditable {btAvatar.enabled = false}
                if let userImageFile = user![User.AvatarFile] as? PFFile {
                    userImageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                if let image = UIImage(data:imageData){
                                    btAvatar.setPhoto(image)
                                }else{
                                    println("couldnt retrieve profile image")
                                }
                            }
                        }
                    }
                }else{
                    println("no profile image")
                }
                
                
                var tfFirst = cell.contentView.viewWithTag(2) as! UITextField
                if let str = user![User.FirstName] as? String {
                    tfFirst.text = str
                }
                
                var tfLast = cell.contentView.viewWithTag(3) as! UITextField
                if let str = user![User.LastName] as? String {
                    tfLast.text = str
                }
                
                var tfNPA = cell.contentView.viewWithTag(4) as! UITextField
                if let str = user![User.npa] as? String {
                    tfNPA.text = str
                }
                
                var btEdit = cell.contentView.viewWithTag(5) as! UIButton
                if !isEditable {
                    btEdit.hidden = true
                }*/
                
            case 1: cell = tableView.dequeueReusableCellWithIdentifier("profile_message", forIndexPath: indexPath) as! UITableViewCell
                
            case 2: cell = tableView.dequeueReusableCellWithIdentifier("profile_addToContact", forIndexPath: indexPath) as! UITableViewCell
                
            default: cell = UITableViewCell()
            }
            
        case 1 :
            if (indexPath.row == skillz.count) {
                cell = tableView.dequeueReusableCellWithIdentifier("profile_add", forIndexPath: indexPath) as! UITableViewCell
            }else{
                cell = tableView.dequeueReusableCellWithIdentifier("profile_skill", forIndexPath: indexPath) as! UITableViewCell
                var lb = cell.contentView.viewWithTag(1) as! UILabel
                let skill = skillz[indexPath.row]
                lb.text = skill[Skill.Title] as? String
            }
        case 2 :
            cell = tableView.dequeueReusableCellWithIdentifier("profile_logout", forIndexPath: indexPath) as! UITableViewCell
        default :
            cell = UITableViewCell()
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (self.isEditable && indexPath.section == 1 && indexPath.row < skillz.count) {return true}
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete){
            user!.relationForKey(User.skills).removeObject(self.skillz[indexPath.row])
            user!.saveInBackground()
            self.skillz.removeAtIndex(indexPath.row)
            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func updateSkills (){
        
        user!.relationForKey(User.skills).query()!.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil){
                self.skillz.removeAll(keepCapacity: true)
                if let objects = objects as? [PFObject]{
                    self.skillz = objects
                    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                }
                else{println("malformed parse response")}
            }
            else{println("Network error")}
        }
    }
    
    @IBAction func btMessageTouched(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("SendMessage", object: user)
    }
    
    @IBAction func btContactTouched(sender: AnyObject) {
        let currentUser = PFUser.currentUser()!
        currentUser.relationForKey(User.contacts).addObject(user!)
        currentUser.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("ContactsUpdated", object: nil)
        }
    }
    
    @IBAction func logoutPressed(sender: AnyObject) {
        PFUser.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}