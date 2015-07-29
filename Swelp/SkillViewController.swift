//
//  SkillViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 16.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SkillViewController: UITableViewController {
    var lst = [PFObject]()
    var category : PFObject?
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cat = self.category {
            
            let relation = cat.relationForKey(SkillCategory.Skills)
            relation.query()!.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
                if (error == nil){
                    self.lst.removeAll(keepCapacity: true)
                    if let objects = objects as? [PFObject]{
                        self.lst = objects
                        self.tableView.reloadData()
                    }
                }
                else{println("Network error")}
            }
        }
        else{println("category id not set")}
        
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("skill_cell", forIndexPath: indexPath) as! UITableViewCell
        var lb = cell.contentView.viewWithTag(1) as! UILabel
        let cat = lst[indexPath.row]
        lb.text = cat[Skill.Title] as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lst.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var user = PFUser.currentUser()!
        user.relationForKey(User.skills).addObject(lst[indexPath.row])
        user.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("ProfileUpdateSkills", object: nil)
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}