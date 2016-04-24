//
//  receivedViewController.swift
//  karma3
//
//  Created by Jared Gutierrez on 4/8/16.
//  Copyright © 2016 Jared Gutierrez. All rights reserved.
//

import UIKit
import Parse

class receivedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
//    
//    var sendtextfield = UITextField(frame: CGRectMake(10, 5, UIScreen.mainScreen().bounds.width - 20, 95))
//    
//    var sendbutton = UIButton( frame: CGRectMake(300, 56 ,50, 40
//    ))
    var refresher:UIRefreshControl!
    var currentIndex = -1;
    //var currUser = PFUser.currentUser()
    //var userId = PFUser.currentUser()!.objectId
    var messages = Array<PFObject>()
    var toApprove = Array<PFObject>()
    var toFlag = Array<PFObject>()
    
    @IBAction func approveMessagePressed(sender: AnyObject) {
        if let button = sender as? UIButton {
            if let superview = button.superview {
                if let cell = superview.superview as? receivedMessageCollectionViewCell {
                    let indexPath = receivedMessagesCollectionView.indexPathForCell(cell)
                    let selectedMessage = messages[indexPath!.row]
                    if !(toApprove.contains(selectedMessage)) {
                        toApprove.append(selectedMessage)
                    }
                    if (toFlag.contains(selectedMessage)) {
                        let index = toApprove.indexOf(selectedMessage)
                        toFlag.removeAtIndex(index!)
                    }
                    
                    cell.backgroundColor = UIColor.greenColor()
                }
            }
        }
    }
    @IBAction func flagMessagePressed(sender: AnyObject) {
        if let button = sender as? UIButton {
            if let superview = button.superview {
                if let cell = superview.superview as? receivedMessageCollectionViewCell {
                    let indexPath = receivedMessagesCollectionView.indexPathForCell(cell)
                    let selectedMessage = messages[indexPath!.row]
                    if !(toFlag.contains(selectedMessage)) {
                        toFlag.append(selectedMessage)
                    }
                    if (toApprove.contains(selectedMessage)) {
                        let index = toApprove.indexOf(selectedMessage)
                        toApprove.removeAtIndex(index!)
                    }
                    cell.backgroundColor = UIColor.redColor()
                }
            }
        }
    }
    func getMessages() {
        // Get the list of all the social titles and add them to the socialLabels array. Then reload the collectionview.
        messages.removeAll()
        
        
        let query = PFQuery(className:"Messages")
        query.orderByDescending("sentDate")
        query.whereKey("authorized", notEqualTo: true)
        query.whereKey("flagged", notEqualTo: true)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) socials.")
                
                
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        
                        self.messages.append(object)
                    }
                    self.receivedMessagesCollectionView.reloadData()
                    self.refresher.endRefreshing()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func approveMessages() {
        for message in toApprove {
            message["authorized"] = true
            do {
                try message.save()
            } catch _ {
                print("failed")
            }
            
        }
        for message in toFlag {
            message["flagged"] = true
            do {
                try message.save()
            } catch _ {
                print("failed")
            }
        }
        getMessages()
    }
    
    func cleanTime(sentDate: NSDate) -> String {
        
        var timeInterval : NSTimeInterval = sentDate.timeIntervalSinceNow
        timeInterval = timeInterval * -1
        
        //print(timeInterval)
        if timeInterval < 60 {
            return "Just now"
        } else if timeInterval < (60 * 60) {
            let numMinutes = Int(floor(timeInterval / 60))
            return String(numMinutes) + " minutes ago"
        } else if timeInterval < (2*60*60) {
            return "1 hour ago"
        } else if timeInterval < (24*60*60) {
            let numHours = Int(floor(timeInterval / (60*60)))
            return String(numHours) + " hours ago"
        } else if timeInterval < (48 * 60 * 60) {
            return "1 day ago"
        } else if timeInterval < (7 * 24 * 60 * 60) {
            let numDays = Int(floor(timeInterval / (24*60*60)))
            return String(numDays) + " days ago"
        } else if timeInterval < (2 * 7 * 24 * 60 * 60) {
            return "1 week ago"
        } else if timeInterval < (30 * 24 * 60 * 60) {
            let numWeeks = Int(floor(timeInterval / (7*24*60*60)))
            return String(numWeeks) + " weeks ago"
        } else if timeInterval < (2 * 30 * 24 * 60 * 60) {
            return "1 month ago"
        } else if timeInterval < (365 * 24 * 60 * 60) {
            let numMonths = Int(floor(timeInterval / (30*24*60*60)))
            return String(numMonths) + " months ago"
        } else if timeInterval < (365 * 24 * 60 * 60) {
            return "1 year ago"
        }
        
        let numYears = Int(floor(timeInterval / (365*24*60*60)))
        return String(numYears) + " years ago"
        
    }
    
    func approveAll() {
        for message in messages {
            toApprove.append(message);
        }
        approveMessages()
    }
    
    func refresh() {
        currentIndex = -1;
        getMessages()
        
    }

    
    @IBOutlet weak var receivedMessagesCollectionView: UICollectionView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        receivedMessagesCollectionView.dataSource = self
        receivedMessagesCollectionView.delegate = self
        receivedMessagesCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false;
        //UIColor(red: 0.965, green: 0.698, blue: 0.42, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.topItem!.title = ":)";
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Approve All", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(receivedViewController.approveAll))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Approve Selected", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(receivedViewController.approveMessages))
        
        getMessages()
        
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let screenWidth = screenSize.width
        
        self.view.backgroundColor = UIColor.greenColor()
        receivedMessagesCollectionView.frame.size.width = screenWidth
        receivedMessagesCollectionView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        
        receivedMessagesCollectionView.backgroundView = nil;
        
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action:#selector(receivedViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        receivedMessagesCollectionView.addSubview(refresher)

        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       
        
        
    }
        
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = receivedMessagesCollectionView.dequeueReusableCellWithReuseIdentifier("recCell", forIndexPath: indexPath) as!receivedMessageCollectionViewCell
        
        //modify the cell
        cell.backgroundColor = UIColor.whiteColor();
        let currMessage = messages[indexPath.row]
        if toApprove.contains(currMessage) {
            cell.backgroundColor = UIColor.greenColor();
        }
        if toFlag.contains(currMessage) {
            cell.backgroundColor = UIColor.redColor();
        }
        //255, 184, 77
        cell.backgroundView = nil;
        //print(body);
        cell.message.text = messages[indexPath.row]["messageBody"] as! String
        cell.time.text = cleanTime((messages[indexPath.row]["sentDate"] as? NSDate)!)
        cell.location.text = messages[indexPath.row]["audience"] as! String
        
        
        
        let collectionViewWidth = receivedMessagesCollectionView.bounds.size.width
        cell.frame.size.width = collectionViewWidth
        cell.frame.origin.x = receivedMessagesCollectionView.frame.origin.x
        
        
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 1
        
        
        cell.layer.shadowOffset = CGSizeMake(0, 3)
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        
        cell.layer.shadowOpacity = 0.9
        
        
        // Maybe just me, but I had to add it to work:
        cell.clipsToBounds = false
        
        let shadowFrame: CGRect = (cell.layer.bounds)
        let shadowPath: CGPathRef = UIBezierPath(rect: shadowFrame).CGPath
        cell.layer.shadowPath = shadowPath
        
        
        
        
        
        return cell
    }
    
    


    
    
    
        
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
        
}


