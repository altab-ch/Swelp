//
//  SearchDataViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 14.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit

class SearchDataViewController: UITableViewController, UISearchResultsUpdating {
    
    var lst = ["1", "23", "3", "34", "45"]
    var filteredLst = [String]()
    var searchDataDelegate : SearchDataProtocol?
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController){
        let str = searchController.searchBar.text
        filteredLst = lst.filter {(includeElement: String) -> Bool in
            return includeElement.rangeOfString(str) != nil
        }
        self.tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLst.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("data_cell", forIndexPath: indexPath) as! UITableViewCell
        var lb = cell.contentView.viewWithTag(1) as! UILabel
        lb.text = filteredLst[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let sdd = self.searchDataDelegate {
            sdd.didSelectData(filteredLst[indexPath.row])
        }
    }
    
}