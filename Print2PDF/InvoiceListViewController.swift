//
//  InvoiceListViewController.swift
//  Print2PDF
//
//  Created by Gabriel Theodoropoulos on 14/06/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class InvoiceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblInvoices: UITableView!
    
    
    var invoices: [[String: AnyObject]]!
    
    var selectedInvoiceIndex: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblInvoices.delegate = self
        tblInvoices.dataSource = self
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let inv = NSUserDefaults.standardUserDefaults().objectForKey("invoices") {
            invoices = inv as? [[String: AnyObject]]
            tblInvoices.reloadData()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "idSeguePresentPreview" {
                let previewViewController = segue.destinationViewController as! PreviewViewController
                previewViewController.invoiceInfo = invoices[selectedInvoiceIndex]
            }
        }
    }
    

    
    // MARK: IBAction Methods
    
    @IBAction func createInvoice(sender: AnyObject) {
        let creatorViewController = storyboard?.instantiateViewControllerWithIdentifier("idCreateInvoice") as! CreatorViewController
        creatorViewController.presentCreatorViewControllerInViewController(self) { (invoiceNumber, recipientInfo, totalAmount, items) in
            dispatch_async(dispatch_get_main_queue(), { 
                if self.invoices == nil {
                    self.invoices = [[String: AnyObject]]()
                }
                
                // Add the new invoice data to the invoices array.
                self.invoices.append(["invoiceNumber": invoiceNumber, "invoiceDate": self.formatAndGetCurrentDate(), "recipientInfo": recipientInfo, "totalAmount": totalAmount, "items": items])
                
                // Update the user defaults with the new invoice.
                NSUserDefaults.standardUserDefaults().setObject(self.invoices, forKey: "invoices")
                
                // Reload the tableview.
                self.tblInvoices.reloadData()
            })
        }
    }
    
    
    // MARK: Custom Methods
    
    func formatAndGetCurrentDate() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        return dateFormatter.stringFromDate(NSDate())
    }
    
    
    // MARK: UITableView Delegate and Datasource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (invoices != nil) ? invoices.count : 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("invoiceCell", forIndexPath: indexPath)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "invoiceCell")
        }
        
        cell.textLabel?.text = "\(invoices[indexPath.row]["invoiceNumber"] as! String) - \(invoices[indexPath.row]["invoiceDate"] as! String) - \(invoices[indexPath.row]["totalAmount"] as! String)"
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedInvoiceIndex = indexPath.row
        performSegueWithIdentifier("idSeguePresentPreview", sender: self)
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            invoices.removeAtIndex(indexPath.row)
            tblInvoices.reloadData()
            NSUserDefaults.standardUserDefaults().setObject(self.invoices, forKey: "invoices")
        }
    }
    
    
}
