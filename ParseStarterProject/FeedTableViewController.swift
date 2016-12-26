//
//  FeedTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by David on 12/23/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {
    private let CELL_REUSE_IDENTIFIER = "Cell"
    private var users : [String: String] = [:]
    private var messages : [String] = []
    private var userNames : [String] = []
    private var images : [PFFile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromParse()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return images.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_REUSE_IDENTIFIER, for: indexPath) as! FeedTableViewCell
        // Configure the cell...
        loadImages(cell: cell, indexPath: indexPath)
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    private func loadImages(cell: FeedTableViewCell, indexPath: IndexPath) {
        self.images[indexPath.row].getDataInBackground(block: {
            (result, error) in
            if error != nil {
                print(error!)
            } else if let downloadedImage = UIImage(data: result!) {
                cell.postedImageView.image = downloadedImage
            }
        })
        cell.userLabel.text = userNames[indexPath.row]
        cell.descriptionLabel.text = messages[indexPath.row]
    }
    
    private func getDataFromParse() -> Void {
        getUsers()
        getFollowers()
    }
    
    private func getUsers() -> Void {
        let query = PFUser.query()
        query?.findObjectsInBackground(block: {
            (objects, error) in
            if (error != nil) {
                print(error!)
            } else {
                for object in (objects as? [PFUser])!{
                    self.users.updateValue(object.username!, forKey: object.objectId!)
                }
            }
        })
    }
    
    private func getFollowers() -> Void {
        let getFollowersQuery = PFQuery(className: "Followers")
        getFollowersQuery.whereKey("follower", equalTo: (PFUser.current()?.objectId)!)
        getFollowersQuery.findObjectsInBackground(block: {
            (objects, error) in
            if (error != nil) {
                print(error!)
            } else {
                for object in objects as [PFObject]! {
                    let followedUser = object["following"] as! String
                    let query = PFQuery(className: "Posts")
                    query.whereKey("userId", equalTo: followedUser)
                    query.findObjectsInBackground(block: {
                        (objects, error) in
                        if (error != nil) {
                            print(error!)
                        } else {
                            for object in objects as [PFObject]! {
                                self.messages.append(object["message"] as! String)
                                self.images.append(object["imageFile"] as! PFFile)
                                self.userNames.append(self.users[object["userId"] as! String]!)
                                self.tableView.reloadData()
                            }
                        }
                        
                    })
                }
            }
        })
    }
}
