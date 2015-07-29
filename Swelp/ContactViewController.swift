//
//  ContactViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 17.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class ContactViewController: UITableViewController {
    var contacts = [PFObject]()
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateContacts"), name: "ContactsUpdated", object: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateContacts()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contact_cell", forIndexPath: indexPath) as! UITableViewCell
        var im = cell.contentView.viewWithTag(1) as! PFImageView
        im.file = contacts[indexPath.row][User.AvatarFile] as? PFFile
        im.loadInBackground()
        var lb = cell.contentView.viewWithTag(2) as! UILabel
        lb.text = contacts[indexPath.row][User.FirstName] as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete){
            let currentUser = PFUser.currentUser()!
            currentUser.relationForKey(User.contacts).removeObject(self.contacts[indexPath.row])
            currentUser.saveInBackground()
            self.contacts.removeAtIndex(indexPath.row)
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func updateContacts () {
        let currentUser = PFUser.currentUser()!
        let relation = currentUser.relationForKey(User.contacts)
        relation.query()!.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let objects = objects as? [PFObject] {
                self.contacts = objects
                self.tableView.reloadData()
            }
        }
    }
    
}