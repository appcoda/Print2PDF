//
//  CreatorViewController.swift
//  Print2PDF
//
//  Created by Gabriel Theodoropoulos on 14/06/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class CreatorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblInvoiceItems: UITableView!
    
    @IBOutlet weak var bbiTotal: UIBarButtonItem!
    
    @IBOutlet weak var tvRecipientInfo: UITextView!
    
    
    var invoiceNumber: String!
    
    var items: [[String: String]]!
    
    var totalAmount = "0"
    
    var saveCompletionHandler: ((invoiceNumber: String, recipientInfo: String, totalAmount: String, items: [[String: String]]) -> Void)!
    
    var firstAppeared = true
    
    var nextNumberAsString: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set self as the delegate and the datasource of the tableview.
        tblInvoiceItems.delegate = self
        tblInvoiceItems.dataSource = self
        
        
        // Add a tap gesture recognizer to the view to dismiss the keyboard.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstAppeared {
            determineInvoiceNumber()
            displayTotalAmount()
            firstAppeared = false
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: IBAction Methods
    
    @IBAction func addItem(sender: AnyObject) {
        let addItemViewController = storyboard?.instantiateViewControllerWithIdentifier("idAddItem") as! AddItemViewController
        addItemViewController.presentAddItemViewControllerInViewController(self) { (itemDescription, price) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                if self.items == nil {
                    self.items = [[String: String]]()
                }
                
                self.items.append(["item": itemDescription, "price": price])
                self.tblInvoiceItems.reloadData()
                
                self.displayTotalAmount()
            })
        }
    }
    
    
    @IBAction func saveInvoice(sender: AnyObject) {
        if saveCompletionHandler != nil {
            if nextNumberAsString != nil {
                NSUserDefaults.standardUserDefaults().setObject(nextNumberAsString, forKey: "nextInvoiceNumber")
            }
            else {
                NSUserDefaults.standardUserDefaults().setObject("002", forKey: "nextInvoiceNumber")
            }
            
            saveCompletionHandler(invoiceNumber: invoiceNumber, recipientInfo: tvRecipientInfo.text, totalAmount: bbiTotal.title!, items: items)
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    // MARK: Custom Methods
    
    func presentCreatorViewControllerInViewController(originalViewController: UIViewController, saveCompletionHandler: (invoiceNumber: String, recipientInfo: String, totalAmount: String, items: [[String: String]]) -> Void) {
        self.saveCompletionHandler = saveCompletionHandler
        originalViewController.navigationController?.pushViewController(self, animated: true)
    }
    
    
    func determineInvoiceNumber() {
        // Get the invoice number from the user defaults if exists.
        if let nextInvoiceNumber = NSUserDefaults.standardUserDefaults().objectForKey("nextInvoiceNumber") {
            invoiceNumber = nextInvoiceNumber as! String
            
            // Save the next invoice number to the user defaults.
            let nextNumber = Int(nextInvoiceNumber as! String)! + 1
            
            if nextNumber < 10 {
                nextNumberAsString = "00\(nextNumber)"
            }
            else if nextNumber < 100 {
                nextNumberAsString = "0\(nextNumber)"
            }
            else {
                nextNumberAsString = "\(nextNumber)"
            }
        }
        else {
            // Specify the first invoice number.
            invoiceNumber = "001"
        }
        
        // Set the invoice number to the navigation bar's title.
        navigationItem.title = invoiceNumber
    }
    
    
    func calculateTotalAmount() {
        var total: Double = 0.0
        if items != nil {
            for invoiceItem in items {
                let priceAsNumber = NSNumberFormatter().numberFromString(invoiceItem["price"]!)
                total += Double(priceAsNumber!)
            }
        }
        
        totalAmount = AppDelegate.getAppDelegate().getStringValueFormattedAsCurrency("\(total)")
    }
    
    
    func displayTotalAmount() {
        calculateTotalAmount()
        bbiTotal.title = totalAmount
    }
    
    
    func dismissKeyboard() {
        if tvRecipientInfo.isFirstResponder() {
            tvRecipientInfo.resignFirstResponder()
        }
    }
    
    
    // MARK: UITableView Delegate and Datasource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (items != nil) ? items.count : 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "itemCell")
        }
        
        cell.textLabel?.text = items[indexPath.row]["item"]
        cell.detailTextLabel?.text = AppDelegate.getAppDelegate().getStringValueFormattedAsCurrency(items[indexPath.row]["price"]!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            items.removeAtIndex(indexPath.row)
            tblInvoiceItems.reloadData()
            displayTotalAmount()
        }
    }
    
}
