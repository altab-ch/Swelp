//
//  ProfileInfoCell.swift
//  Swelp
//
//  Created by Mathieu Knecht on 17.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ProfileInfoCell: UITableViewCell {
    
    var isEditable: Bool = false
    
    var user: PFUser?
    
    @IBOutlet weak var btAvatar: AvatarButton!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfNpa: UITextField!
    @IBOutlet weak var btEdit: UIButton!
    
    func setUser(us: PFUser, editable:Bool) {
        
        self.user = us
        self.isEditable = editable
        
        if !isEditable {btAvatar.enabled = false}
        if let userImageFile = user![User.AvatarFile] as? PFFile {
            userImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        if let image = UIImage(data:imageData){
                            self.btAvatar.setPhoto(image)
                        }else{
                            println("couldnt retrieve profile image")
                        }
                    }
                }
            }
        }else{
            println("no profile image")
        }
        
        self.tfFirstName.text = user![User.FirstName] as? String
        self.tfLastName.text = user![User.LastName] as? String
        
        if let str = user![User.FirstName] as? String {
            tfFirstName.text = str
        }
        
        if let str = user![User.LastName] as? String {
            tfLastName.text = str
        }
        
        if let str = user![User.npa] as? String {
            tfNpa.text = str
        }
        
        if !isEditable {
            btEdit.hidden = true
        }
        
        
    }
    
    @IBAction func btEditTouched(sender: AnyObject) {
        tfFirstName.enabled = !tfFirstName.enabled
        tfLastName.enabled = !tfLastName.enabled
        tfNpa.enabled = !tfNpa.enabled
        btAvatar.enabled = !btAvatar.enabled
    }
}