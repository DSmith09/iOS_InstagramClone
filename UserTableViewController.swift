//
//  UserTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by David on 12/21/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {
    private let REUSE_IDENTIFIER = "Cell"
    private let LOGOUT_SEGUE = "logoutSegue"
    private var users: [PFUser] = []
    private var userNames: [String] = []
    private var userIDs: [String] = []
    private var isFollowing: [String: Bool] = [:]
    private var refresher: UIRefreshControl!

    @IBAction func logoutButton(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: LOGOUT_SEGUE, sender: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserList()
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refresher.addTarget(self, action: #selector(UserTableViewController.getUserList), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
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

    // Sections = Columns
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: REUSE_IDENTIFIER, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = userNames[indexPath.row]
        if isFollowing[userIDs[indexPath.row]]! {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        return cell
    }

    // Method for when cell is clicked
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if isFollowing[userIDs[indexPath.row]]! {
            cell?.accessoryType = UITableViewCellAccessoryType.none
            deleteFollower(indexPath: indexPath)
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            addFollower(indexPath: indexPath)
        }
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

    private func deleteFollower(indexPath: IndexPath) -> Void {
        isFollowing.updateValue(false, forKey: userIDs[indexPath.row])
        let unfollow = PFQuery(className: "Followers")
        unfollow.whereKey("following", equalTo: userIDs[indexPath.row])
        unfollow.findObjectsInBackground(block: {
            (objects, error) in
            if (error != nil) {
                print(error!)
            } else {
                for object in objects! {
                    object.deleteInBackground()
                }
            }
        })
    }

    private func addFollower(indexPath: IndexPath) -> Void {
        isFollowing.updateValue(true, forKey: userIDs[indexPath.row])
        let following = PFObject(className: "Followers")
        following["follower"] = PFUser.current()?.objectId
        following["following"] = userIDs[indexPath.row]
        following.saveInBackground()
    }

    @objc private func getUserList() -> Void {
        let query = PFUser.query()
        query?.findObjectsInBackground(block: {
            (objects, error) in
            if error != nil {
                print(error!)
            } else if let users = objects as? [PFUser] {
                for user in users {
                    if user.objectId != PFUser.current()?.objectId {
                        self.users.append(user)
                        self.userIDs.append(user.objectId!)
                        let userName = user.username!.components(separatedBy: "@")
                        self.userNames.append(userName[0])
                        let query = PFQuery(className: "Followers")
                        query.whereKey("following", equalTo: user.objectId!)

                        query.findObjectsInBackground(block: {
                            (objects, error) in
                            if error != nil {
                                print(error!)
                            } else {
                                if (objects?.count)! > 0 {
                                    self.isFollowing.updateValue(true, forKey: user.objectId!)
                                } else {
                                    self.isFollowing.updateValue(false, forKey: user.objectId!)
                                }
                                if self.isFollowing.count == self.userNames.count {
                                    self.tableView.reloadData()
                                }
                            }
                        })
                    }
                }
                self.refresher.endRefreshing()
            }
        })
    }
}
