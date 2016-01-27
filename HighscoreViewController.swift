//
//  HighscoreViewController.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 27/01/16.
//
//

import UIKit
import Parse

class HighscoreViewController: UIViewController, UITableViewDataSource {
    var caller: UIViewController?
    var highscores: [PFObject] = []
    
    override func viewDidLoad() {
        tableView.dataSource = self
        
        let query = PFQuery(className: "Highscore")
        query.orderByDescending("Score")
        query.includeKey("User")
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    self.highscores = objects
                    self.tableView.reloadData()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func logoutClicked(sender: AnyObject) {
        logout()
    }
    @IBAction func backClicked(sender: AnyObject) {
        caller?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func logout() {
        PFUser.logOut()
        PFAnonymousUtils.logInInBackground()
    }
    
    func setCallerViewController(viewController: UIViewController) {
        self.caller = viewController
    }
    
    // MARK TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highscores.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //variable type is inferred
        var cell = tableView.dequeueReusableCellWithIdentifier("identifier")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }
        
        //we know that cell is not empty now so we use ! to force unwrapping
        
        let highscore = highscores[indexPath.row]
        
        if let score = highscore.objectForKey("Score") as? Int,
            let userId = highscore.objectForKey("User")!.objectId {
                cell!.textLabel?.text = "\(indexPath.row + 1) : \(userId!) - \(score)"
                
                if userId == PFUser.currentUser()?.objectId {
                    cell!.backgroundColor = UIColor.lightGrayColor()
                }
        }
        
        return cell!
    }
}