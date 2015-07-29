//
//  MessagesViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 19.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import Parse
import JSQMessagesViewController

class MessagesViewController: JSQMessagesViewController {
    
    var contact : PFUser?
    var chatID : String = ""
    var messages = [JSQMessage]()
    var isLoadingMessages = false
    var avatarImageBlank = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "chat_blank"), diameter: 30)
    
    var bubbleImageIncoming = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.blueColor())
    var bubbleImageOutgoing = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.greenColor())
    var reloadTimer : NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("recentReloadData:"), name: "RecentReloadData", object: nil)
        
        if contact == nil {
            println("Error : contact not init")
            return
        }
        
        let user = PFUser.currentUser()!
        chatID = self.createChatID(user, user2: contact!)
        
        automaticallyScrollsToMostRecentMessage = true
        self.senderId = user.objectId
        self.senderDisplayName = user[User.FirstName] as! String
        
        self.loadMessages()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
        reloadTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("loadMessages"), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        reloadTimer?.invalidate()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if !text.isEmpty
        {
            self.sendMessage(text)
        }
        
    }
    
    func loadMessages () {
        if !isLoadingMessages {
            isLoadingMessages = true
            var query = PFQuery(className: Message.ClassName)
            query.whereKey(Message.ChatID, equalTo: chatID)
            
            if messages.count != 0 {
                println(messages.last!.date)
                query.whereKey(Message.createdAt, greaterThan: messages.last!.date)
            
            }
            
            query.includeKey(Message.User)
            query.orderByAscending(Message.createdAt)
            query.limit = 50
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil {
                    if let objects = objects as? [PFObject]{
                        for mes in objects {
                            self.addMessage(mes)
                        }
                        
                        if objects.count != 0
                        {
                            self.finishReceivingMessage()
                        }
                        self.isLoadingMessages = false
                        
                    }
                }else{println("Network error")}
            })
        }
    
    }
    
    func recentReloadData (notification: NSNotification){
        self.loadMessages()
    }
    
    func addMessage (message: PFObject!){
        let user = message[Message.User] as! PFUser
        let name = user[User.FirstName] as! String
        let jsqMessage = JSQMessage(senderId: user.objectId, displayName: name, text: message[Message.Text] as! String)
        messages.append(jsqMessage)
    }
    
    func sendMessage (text : String!){
        var object = PFObject(className: Message.ClassName)
        object[Message.ChatID] = chatID
        object[Message.User] = PFUser.currentUser()!
        object[Message.Text] = text
        object.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentAlert()
                self.loadMessages()
                
            }else{println("Network error")}
        }
        
        SendPushNotification(contact, text)
        updateRecent(chatID, withMessage: text, andAmount: 1)
        
        finishSendingMessage()
        
    }
    
    func updateRecent (chatId: String, withMessage message: String, andAmount amount: Int) {
        var query = PFQuery(className: Recent.ClassName)
        query.whereKey(Recent.ChatID, equalTo: chatID)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if (error == nil) {
                if let objects = objects as? [PFObject]{
                    let currentUser = PFUser.currentUser()!
                    if objects.count == 0 {
                        self.createRecent(self.contact!, message: message, contact: currentUser)
                        self.createRecent(currentUser, message: message, contact: self.contact!)
                    }else if (objects.count == 2){
                        for recent in objects {
                            let lastUser = recent[Recent.LastUser] as! PFUser
                            if lastUser.objectId == currentUser.objectId {
                                recent.incrementKey(Recent.Counter)
                            }else{
                                recent[Recent.Counter] = 1
                                recent[Recent.LastUser] = currentUser
                            }
                            recent[Recent.LastMessage] = message
                            recent[Recent.Date] = NSDate()
                            recent.saveInBackgroundWithBlock({ (success, error) -> Void in
                                if error != nil {println("Cant save recent")}
                            })
                        }
                    }else {println("Struct error")}
                    NSNotificationCenter.defaultCenter().postNotificationName("RecentReloadData", object: nil)
                }
            }else {println("Network error")}
        }
    }
    
    func createRecent (user: PFUser!, message: String!, contact: PFUser!) {
        var recent = PFObject(className: Recent.ClassName)
        recent[Recent.ChatID] = chatID
        recent[Recent.User] = user
        recent[Recent.LastUser] = PFUser.currentUser()!
        recent[Recent.LastMessage] = message
        recent[Recent.Date] = NSDate()
        recent[Recent.Contact] = contact
        recent[Recent.Counter] = 1
        recent.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {println("Cant create recent")}
            else {}
        }
    }
    
    func createChatID (user1 : PFUser, user2 : PFUser) -> String {
        return user1.objectId!.compare(user2.objectId!)==NSComparisonResult.OrderedAscending ? user1.objectId! + user2.objectId! : user2.objectId! + user1.objectId!
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return avatarImageBlank
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        if messages[indexPath.row].senderId == self.senderId {
            return bubbleImageOutgoing
        }
        return bubbleImageIncoming
    }
}