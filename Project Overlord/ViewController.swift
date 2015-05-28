//
//  ViewController.swift
//  Project Overlord
//
//  Created by Mike Burkle on 5/28/15.
//  Copyright (c) 2015 Mike Burkle. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    var bugData = []
    var devData = []
    var readyData = []
    var completeData = []
    var tableData = []
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var appsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchOverlordFor("7")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:    Int) -> Int {
        return tableData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        
        if let rowData: NSDictionary = self.tableData[indexPath.row] as? NSDictionary {
            let cardName = rowData["name"] as String
            let cardDesc = rowData["description"] as String
            cell.textLabel?.text = cardName
            cell.detailTextLabel?.text = cardDesc
        }
        
        return cell
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            self.tableData = self.readyData
            self.appsTableView!.reloadData()
        case 1:
            self.tableData = self.devData
            self.appsTableView!.reloadData()
        case 2:
            self.tableData = self.completeData
            self.appsTableView!.reloadData()
        case 3:
            self.tableData = self.bugData
            self.appsTableView!.reloadData()
        default:
            break; 
        }
    }
    func searchOverlordFor(searchTerm: String) {
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        let overlordSearchTerm = searchTerm
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = overlordSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "http://overlord.ngrok.com/trello/api/\(escapedSearchTerm)/board_card_information"
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                println("Task completed")
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                }
                var err: NSError?
                if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                    println(jsonResult)
                    if(err != nil) {
                        // If there is an error parsing JSON, print it to the console
                        println("JSON Error \(err!.localizedDescription)")
                    }
                    if let bugResults: NSArray = jsonResult["bugs"] as? NSArray {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.bugData = bugResults
                        })
                    }
                    if let devResults: NSArray = jsonResult["underway"] as? NSArray {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.devData = devResults
                        })
                    }
                    if let readyResults: NSArray = jsonResult["ready"] as? NSArray {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.readyData = readyResults
                        })
                    }
                    if let completeResults: NSArray = jsonResult["complete"] as? NSArray {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.completeData = completeResults
                            self.tableData = completeResults
                            self.appsTableView!.reloadData()
                        })
                    }
                }
            })
            
            // The task is just an object with all these properties set
            // In order to actually make the web request, we need to "resume"
            task.resume()
        }
    }
    
}

