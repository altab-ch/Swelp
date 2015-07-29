//
//  RecentViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 19.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class RecentViewController: UITableViewController {
    
    var isMessageLoading = false
    var currentContact : PFUser?
    
    var recents = [PFObject]()
    
    
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("sendMessage:"), name: "SendMessage", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("recentReloadData:"), name: "RecentReloadData", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadRecents()
    }
    
    func sendMessage(notification: NSNotification){
        self.tabBarController?.selectedIndex = 3
        
        if let user = notification.object as? PFUser {
            isMessageLoading = true
            currentContact = user
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isMessageLoading {
            isMessageLoading = false
            self.showChat(currentContact!)
        }
    }
    
    func showChat (contact : PFUser!){
        var messagesVC = MessagesViewController()
        messagesVC.contact = contact
        messagesVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(messagesVC, animated: true)
    }
    
    func recentReloadData(notification: NSNotification){
        self.loadRecents()
    }
    
    func loadRecents () {
        var query = PFQuery(className: Recent.ClassName)
        query.whereKey(Recent.User, equalTo: PFUser.currentUser()!)
        query.includeKey(Recent.LastUser)
        query.includeKey(Recent.Contact)
        query.orderByDescending(Recent.Date)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    self.recents = objects
                    self.tableView.reloadData()
                    self.updateTabBadge()
                }else{println("Malformed recent")}
            }else{println("Network error")}
        }
    }
    
    func updateTabBadge () {
        var total = 0
        for recent in recents {
            total += recent[Recent.Counter]!.integerValue
        }
        
        let tabItem = self.tabBarController!.tabBar.items![3] as! UITabBarItem
        tabItem.badgeValue = total == 0 ? nil : String(total)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("recent_cell", forIndexPath: indexPath) as! UITableViewCell
        
        let avatarImage = cell.contentView.viewWithTag(1) as! PFImageView
        let user = recents[indexPath.row][Recent.Contact] as! PFUser
        avatarImage.file = user[User.AvatarFile] as? PFFile
        avatarImage.loadInBackground()
        
        let lbUser = cell.contentView.viewWithTag(2) as! UILabel
        lbUser.text = user[User.FirstName] as? String
        
        let lbMessage = cell.contentView.viewWithTag(3) as! UILabel
        lbMessage.text = recents[indexPath.row][Recent.LastMessage] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let contact = recents[indexPath.row][Recent.Contact] as! PFUser
        self.showChat(contact)
    }
}