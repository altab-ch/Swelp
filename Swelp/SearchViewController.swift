//
//  SearchViewController.swift
//  Swelp
//
//  Created by Mathieu Knecht on 13.06.15.
//  Copyright (c) 2015 Mathieu Knecht. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

protocol SearchDataProtocol{
    func didSelectData(data: String)
}

class SearchViewController: UITableViewController, UISearchBarDelegate, SearchDataProtocol {
    
    var searchController : UISearchController?
    var searchResult = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var dataController = storyboard.instantiateViewControllerWithIdentifier("SearchData") as? SearchDataViewController
        dataController!.searchDataDelegate = self
        self.searchController = UISearchController(searchResultsController: dataController)
        self.searchController!.searchResultsUpdater = dataController
        self.searchController!.dimsBackgroundDuringPresentation = false
        self.searchController!.searchBar.delegate = self
        self.tableView.tableHeaderView = self.searchController!.searchBar
        self.definesPresentationContext = true
        self.searchController!.searchBar.sizeToFit()
        self.searchController?.hidesNavigationBarDuringPresentation = false
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let str = searchBar.text
        searchController?.active = false
        self.searchController!.searchBar.text = str
        self.navigationController?.hidesBarsOnSwipe = true
        self.search()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.navigationController?.hidesBarsOnSwipe = false
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    func didSelectData(data: String) {
        searchController?.active = false
        self.searchController!.searchBar.text = data
        self.navigationController?.hidesBarsOnSwipe = true
        self.search()
    }
    
    func search(){
        let str = self.searchController!.searchBar.text
        var querySkill = PFQuery(className: Skill.ClassName)
        querySkill.whereKey(Skill.Title, containsString: str)
        var queryUser = PFUser.query()!
        queryUser.whereKey(User.skills, matchesQuery: querySkill)
        
        //let finalQuery = PFQuery.orQueryWithSubqueries([query, queryKeywords])
        queryUser.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error:NSError?) -> Void in
            if let objects = objects as? [PFObject] {
                self.searchResult = objects
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("search_cell", forIndexPath: indexPath) as! UITableViewCell
        var im = cell.contentView.viewWithTag(1) as! PFImageView
        im.file = searchResult[indexPath.row][User.AvatarFile] as? PFFile
        im.loadInBackground()
        var lb = cell.contentView.viewWithTag(2) as! UILabel
        lb.text = searchResult[indexPath.row][User.FirstName] as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("contact_segue", sender: searchResult[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let user = sender as? PFUser {
            let vc = segue.destinationViewController as! ProfileViewController
            vc.user = user
        }
    }
}