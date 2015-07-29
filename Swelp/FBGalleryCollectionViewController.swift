//
//  FBGalleryCollectionViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 24.05.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import AFNetworking

class FBGalleryCollectionViewController: UICollectionViewController {
    
    var json : JSON?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (json != nil) {
            if let gallery = json!["images"].array {
                return gallery.count
            }
        }
        
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("thumb", forIndexPath: indexPath) as! UICollectionViewCell
        
        return cell
    }
}