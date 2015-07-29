//
//  FBAlbumTableViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 23.05.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import FBSDKCoreKit
import AFNetworking
import Parse

class FBAlbumTableViewController: UITableViewController {
    
    var album : [JSON]?
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.requestFacebook()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (album != nil){
            return album!.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("album") as! UITableViewCell
        var title = cell.contentView.viewWithTag(1) as! UILabel
        var image = cell.contentView.viewWithTag(2) as! UIImageView
        
        title.text = album![indexPath.row]["from"]["name"].stringValue
        image.setImageWithURL(NSURL(string: album![indexPath.row]["picture"].stringValue))
        cell.tag = indexPath.row
        
        return cell
    }
    
    func requestFacebook() {
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            let id = PFUser.currentUser()![User.Id] as! Int
            let graphpath = String(id)+"/picture"
            let request = FBSDKGraphRequest(graphPath: "me/picture", parameters: nil, HTTPMethod: "GET").startWithCompletionHandler({ (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error: NSError!) -> Void in
                if (error == nil){
                    let json = JSON (result)
                    if json != nil {
                        println(result)
                        self.album = json["data"].arrayValue
                        self.tableView.reloadData()
                    }else{
                        //ProgressHUD.showError("Error connecting Facebook", interaction: true)
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    
                }else{
                    //ProgressHUD.showError("Error connecting Facebook", interaction: true)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "gallery_sg") {
            var galleryVC = segue.destinationViewController as! FBGalleryCollectionViewController
            
            
        }
    }
    
}
