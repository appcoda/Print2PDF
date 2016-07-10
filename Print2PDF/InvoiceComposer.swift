//
//  InvoiceComposer.swift
//  Print2PDF
//
//  Created by Gabriel Theodoropoulos on 23/06/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class InvoiceComposer: NSObject {

    let pathToInvoiceHTMLTemplate = NSBundle.mainBundle().pathForResource("invoice", ofType: "html")
    
    let pathToSingleItemHTMLTemplate = NSBundle.mainBundle().pathForResource("single_item", ofType: "html")
    
    let pathToLastItemHTMLTemplate = NSBundle.mainBundle().pathForResource("last_item", ofType: "html")
    
    let senderInfo = "Gabriel Theodoropoulos<br>123 Somewhere Str.<br>10000 - MyCity<br>MyCountry"
    
    let dueDate = ""
    
    let paymentMethod = "Wire Transfer"
    
    let logoImageURL = "http://www.appcoda.com/wp-content/uploads/2015/12/blog-logo-dark-400.png"
    
    var invoiceNumber: String!
    
    var pdfFilename: String!
    
    
    override init() {
        super.init()
    }
    
    
    func renderInvoice(invoiceNumber: String, invoiceDate: String, recipientInfo: String, items: [[String: String]], totalAmount: String) -> String! {
        // Store the invoice number for future use.
        self.invoiceNumber = invoiceNumber
        
        do {
            // Load the invoice HTML template code into a String variable.
            var HTMLContent = try String(contentsOfFile: pathToInvoiceHTMLTemplate!)
            
            // Replace all the placeholders with real values except for the items.
            // The logo image.
            HTMLContent = HTMLContent.stringByReplacingOccurrencesOfString("#LOGO_IMAGE#", withString: logoImageURL)
            
            // Invoice number.
            HTMLContent = HTMLContent.stringByReplacingOccurrencesOfString("#INVOICE_NUMBER#", withString: invoiceNumber)
            
            // Invoice date.
            HTMLContent = HTMLContent.stringByReplacingOccurrencesOfString("#INVOICE_DATE#", withString: invoiceDate)
            
            // Due date (we leave it blank by default).
            HTMLContent = HTMLContent.stringByReplacingOccurrencesOfString("#DUE_DATE#", withString: dueDate)
            
            // Sender info.
            HTMLContent = HTMLContent.stringByReplacingOccurrencesOfString("#SENDER_INFO#", withString: senderInfo)
            
            // Recipient info.
            HTMLContent = HTMLContent.stringByReplacingOccurrencesOfString("#RECIPIENT_INFO#", withString: recipientInfo.stringByReplacingOccurrencesOfString("\n", withString: "<br>"))
            
            // Payment method.
            HTMLContent = HTMLContent.stringByReplacingOccurrencesOfString("#PAYMENT_METHOD#", withString: paymentMethod)
            
            // Total amount.
            HTMLContent = HTMLContent.stringByReplacingOccurrencesOfString("#TOTAL_AMOUNT#", withString: totalAmount)
            
            // The invoice items will be added by using a loop.
            var allItems = ""
            
            // For all the items except for the last one we'll use the "single_item.html" template.
            // For the last one we'll use the "last_item.html" template.
            for i in 0..<items.count {
                var itemHTMLContent: String!
                
                // Determine the proper template file.
                if i != items.count - 1 {
                    itemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
                }
                else {
                    itemHTMLContent = try String(contentsOfFile: pathToLastItemHTMLTemplate!)
                }
                
                // Replace the description and price placeholders with the actual values.
                itemHTMLContent = itemHTMLContent.stringByReplacingOccurrencesOfString("#ITEM_DESC#", withString: items[i]["item"]!)
                
                // Format each item's price as a currency value.
                let formattedPrice = AppDelegate.getAppDelegate().getStringValueFormattedAsCurrency(items[i]["price"]!)
                itemHTMLContent = itemHTMLContent.stringByReplacingOccurrencesOfString("#PRICE#", withString: formattedPrice)
                
                // Add the item's HTML code to the general items string.
                allItems += itemHTMLContent
            }
            
            // Set the items.
            HTMLContent = HTMLContent.stringByReplacingOccurrencesOfString("#ITEMS#", withString: allItems)
            
            // The HTML code is ready.
            return HTMLContent
            
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        
        return nil
    }
    
    
    func exportHTMLContentToPDF(HTMLContent: String) {
        let printPageRenderer = CustomPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAtIndex: 0)
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer)
        
        pdfFilename = "\(AppDelegate.getAppDelegate().getDocDir())/Invoice\(invoiceNumber).pdf"
        pdfData.writeToFile(pdfFilename, atomically: true)
        
        print(pdfFilename)
    }
    
    
    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRectZero, nil)
        
        UIGraphicsBeginPDFPage()
        
        printPageRenderer.drawPageAtIndex(0, inRect: UIGraphicsGetPDFContextBounds())
        
        UIGraphicsEndPDFContext()
        
        return data
    }
    
}
