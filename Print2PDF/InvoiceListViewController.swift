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

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let inv = UserDefaults.standard.object(forKey: "invoices") {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "idSeguePresentPreview" {
                let previewViewController = segue.destination as! PreviewViewController
                previewViewController.invoiceInfo = invoices[selectedInvoiceIndex]
            }
        }
    }
    

    
    // MARK: IBAction Methods
    
    @IBAction func createInvoice(_ sender: AnyObject) {
        let creatorViewController = storyboard?.instantiateViewController(withIdentifier: "idCreateInvoice") as! CreatorViewController
        creatorViewController.presentCreatorViewControllerInViewController(originalViewController: self) { (invoiceNumber, recipientInfo, totalAmount, items) in
            DispatchQueue.main.async {
                if self.invoices == nil {
                    self.invoices = [[String: AnyObject]]()
                }
                
                // Add the new invoice data to the invoices array.
                self.invoices.append(["invoiceNumber": invoiceNumber as AnyObject, "invoiceDate": self.formatAndGetCurrentDate() as AnyObject, "recipientInfo": recipientInfo as AnyObject, "totalAmount": totalAmount as AnyObject, "items": items as AnyObject])
                
                // Update the user defaults with the new invoice.
                UserDefaults.standard.set(self.invoices, forKey: "invoices")
                
                // Reload the tableview.
                self.tblInvoices.reloadData()
            }
        }
    }
    
    
    // MARK: Custom Methods
    
    func formatAndGetCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        return dateFormatter.string(from: NSDate() as Date)
    }
    
    
    // MARK: UITableView Delegate and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (invoices != nil) ? invoices.count : 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "invoiceCell", for: indexPath as IndexPath)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "invoiceCell")
        }
        
        cell.textLabel?.text = "\(invoices[indexPath.row]["invoiceNumber"] as! String) - \(invoices[indexPath.row]["invoiceDate"] as! String) - \(invoices[indexPath.row]["totalAmount"] as! String)"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedInvoiceIndex = indexPath.row
        performSegue(withIdentifier: "idSeguePresentPreview", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            invoices.remove(at: indexPath.row)
            tblInvoices.reloadData()
            UserDefaults.standard.set(self.invoices, forKey: "invoices")
        }
    }
    
    
}
