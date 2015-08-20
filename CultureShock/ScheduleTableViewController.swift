//
//  ScheduleTableViewController.swift
//  CultureShock
//
//  Created by Joe Shuart on 7/30/15.
//  Copyright (c) 2015 Joe Shuart. All rights reserved.
//

import UIKit
import CoreData

class ScheduleTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var myTableView: UITableView!
    
    var nodeCollection = [Node]()
    
    var service:NodeService!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "CSDC_Schedule_Background.png"))
        
        self.service = NodeService()
        self.service.getNodes {
            (response) in
            
            if let nodes = response["nodes"] as? NSArray {
                self.loadNodes(nodes)
            } else {
                // load from cache
                self.loadNodesFromCoreData()
            }
        }
    }
    
    
    
    func loadNodes(nodes:NSArray){
        
        let fetchRequest = NSFetchRequest(entityName: "Class")
        
        var error: NSError?
        var items = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        
        for item in items {
            managedObjectContext!.deleteObject(item as! NSManagedObject)
        }
        
        var index = 0
        
        for node in nodes {

            var node = node["node"]! as! NSDictionary
            
            var field_class_day_value = node["field_class_day_value"] as! String
            
            var field_class_time_start_value = node["field_class_time_start_value"] as! String
            
            var field_class_time_end_value = node["field_class_time_end_value"] as! String
            
            var field_class_flex_header_value = node["field_class_flex_header_value"] as! String
            
            var title = node["title"] as!String
            
            var field_ages_value = node["field_ages_value"] as? String
            
            var field_class_footer_value = node["field_class_footer_value"] as? String
            
            var field_class_flex_footer_value = node["field_class_flex_footer_value"] as? String
            
            var field_class_instructor_nid = node["field_class_instructor_nid"] as? String
            
            
            switch field_class_day_value {
            case "1":
                field_class_day_value = "Monday"
            case "2":
                field_class_day_value = "Tuesday"
            case "3":
                field_class_day_value = "Wednesday"
            case "4":
                field_class_day_value = "Thursday"
            case "5":
                field_class_day_value = "Friday"
            case "6":
                field_class_day_value = "Saturday"
            default:
                field_class_day_value = "Sunday"}
            
            
            //convert time
            var dataStringStartTime = field_class_time_start_value
            var dataStringEndTime = field_class_time_end_value
            
            var dateFormatter = NSDateFormatter()
            var dateFormatter2 = NSDateFormatter()
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter2.dateFormat = "h:mm a"
            
            let dateValueStartTime = dateFormatter.dateFromString(dataStringStartTime) as NSDate!
            let dateValueEndTime = dateFormatter.dateFromString(dataStringEndTime) as NSDate!
            
            let class_time_start_value = dateFormatter2.stringFromDate(dateValueStartTime)
            let class_time_end_value = dateFormatter2.stringFromDate(dateValueEndTime)
            
            let class_time_final = "\(class_time_start_value) - \(class_time_end_value)"
            
            
            //cleans up the title
            let title_final = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            //provides default values for ages field and instructor if nil
            if(field_ages_value == nil){
                field_ages_value = "All ages"
            }
            if (field_class_instructor_nid == nil){
                field_class_instructor_nid = "TBA"
            }
            
            
            var nodeObj = Node(field_class_day_value: field_class_day_value,
                
                class_time_final: class_time_final,
                
                field_class_flex_header_value: field_class_flex_header_value,
                
                title_final: title_final,
                
                field_ages_value: field_ages_value,
                
                field_class_footer_value: field_class_footer_value,
                
                field_class_flex_footer_value: field_class_flex_footer_value,
                
                field_class_instructor_nid: field_class_instructor_nid)
            
            
            
            nodeCollection.append(nodeObj)
            
            var classObject = NSEntityDescription.insertNewObjectForEntityForName("Class", inManagedObjectContext: managedObjectContext!) as! Class
            classObject.field_class_flex_footer_value = field_class_flex_footer_value
            classObject.field_class_day_value = field_class_day_value
            classObject.class_time_final = class_time_final
            classObject.field_ages_value = field_ages_value
            classObject.field_class_footer_value = field_class_footer_value
            classObject.field_class_flex_header_value = field_class_flex_header_value
            classObject.field_class_instructor_nid = field_class_instructor_nid
            classObject.title_final = title_final
            classObject.index = index
            
            var error:NSError?
            if !self.managedObjectContext!.save(&error) {
                println("\(error)")
            }
            
            index++
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.tableView.reloadData()
                
            }
            
        }
        
    }
    
    func loadNodesFromCoreData() {
        
        let fetchRequest = NSFetchRequest(entityName: "Class")
        
        var error:NSError?
        let fetchedResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [Class]
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        
        if fetchedResults.count == 0 {
            
            var alert = UIAlertController(title: "No internet connection", message: "Culture Shock requires an internet connection the first time the app is run.", preferredStyle: UIAlertControllerStyle.Alert)
            
            var okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                (alert) -> Void in
                //abort()
            }
            alert.addAction(okButton)

            self.presentViewController(alert, animated: true, completion: nil)
    
            return
        }
        
        for node in fetchedResults {
            var field_class_day_value = node.field_class_day_value
            
            var class_time_final = node.class_time_final
            
            var field_class_flex_header_value = node.field_class_flex_header_value
            
            var title_final = node.title_final
            
            var field_ages_value = node.field_ages_value
            
            var field_class_footer_value = node.field_class_footer_value
            
            var field_class_flex_footer_value = node.field_class_flex_footer_value
            
            var field_class_instructor_nid = node.field_class_instructor_nid
            
            var nodeObj = Node(field_class_day_value: field_class_day_value,
                
                class_time_final: class_time_final,
                
                field_class_flex_header_value: field_class_flex_header_value,
                
                title_final: title_final,
                
                field_ages_value: field_ages_value,
                
                field_class_footer_value: field_class_footer_value,
                
                field_class_flex_footer_value: field_class_flex_footer_value,
                
                field_class_instructor_nid: field_class_instructor_nid)
            
            
            
            nodeCollection.append(nodeObj)
            
            
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.tableView.reloadData()
                
            }

            
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Return the number of rows in the section.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return nodeCollection.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : CustomCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomCell
        
        let node = nodeCollection[indexPath.row]
        cell.lbl_day_value.text = node.field_class_day_value
        cell.lbl_class_time_final.text = node.class_time_final
        cell.lbl_flex_header_value.text = node.field_class_flex_header_value
        cell.lbl_title.text = node.title_final
        cell.lbl_ages_value.text = node.field_ages_value
        cell.lbl_footer_value.text = node.field_class_footer_value
        cell.lbl_flex_footer_value.text = node.field_class_flex_footer_value
        cell.lbl_instructor_nid.text = node.field_class_instructor_nid
        
        return cell
    }
    
    
    
    
}

