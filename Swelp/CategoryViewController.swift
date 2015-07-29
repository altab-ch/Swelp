//
//  CategoryViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 15.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import Parse

class CategoryViewController: UITableViewController {
    var lst = [PFObject]()
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let query = PFQuery(className: SkillCategory.ClassName)
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if (error == nil){
                self.lst.removeAll(keepCapacity: true)
                if let objects = objects as? [PFObject]{
                    /*for obj in objects{
                    
                    }*/
                    self.lst = objects
                    self.tableView.reloadData()
                }
                
                
            }
            else{println("Network error")}
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("category_cell", forIndexPath: indexPath) as! UITableViewCell
        var lb = cell.contentView.viewWithTag(1) as! UILabel
        let cat = lst[indexPath.row]
        lb.text = cat[SkillCategory.Title] as? String
        cell.contentView.tag = indexPath.row+10
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lst.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //var user = PFUser.currentUser()!
        //var lst = user[User.skills]! as! Array
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UITableViewCell{
            if let sk = segue.destinationViewController as? SkillViewController{
                sk.category = lst[cell.contentView.tag-10]
            }
        }
    }
}