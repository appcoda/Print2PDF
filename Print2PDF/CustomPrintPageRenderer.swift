//
//  CustomPrintPageRenderer.swift
//  Print2PDF
//
//  Created by Gabriel Theodoropoulos on 24/06/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class CustomPrintPageRenderer: UIPrintPageRenderer {

    let A4PageWidth: CGFloat = 595.2
    
    let A4PageHeight: CGFloat = 841.8
    
    
    override init() {
        super.init()
        
        // Specify the frame of the A4 page.
        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)
        
        // Set the page frame.
        self.setValue(NSValue(CGRect: pageFrame), forKey: "paperRect")
        
        // Set the horizontal and vertical insets (that's optional).
        // self.setValue(NSValue(CGRect: pageFrame), forKey: "printableRect")
        self.setValue(NSValue(CGRect: CGRectInset(pageFrame, 10.0, 10.0)), forKey: "printableRect")
        
        
        self.headerHeight = 50.0
        self.footerHeight = 50.0
    }
    
    
    override func drawHeaderForPageAtIndex(pageIndex: Int, inRect headerRect: CGRect) {
        // Specify the header text.
        let headerText: NSString = "Invoice"
        
        // Set the desired font.
        let font = UIFont(name: "AmericanTypewriter-Bold", size: 30.0)
        
        // Specify some text attributes we want to apply to the header text.
        let textAttributes = [NSFontAttributeName: font!, NSForegroundColorAttributeName: UIColor(red: 243.0/255, green: 82.0/255.0, blue: 30.0/255.0, alpha: 1.0), NSKernAttributeName: 7.5]
        
        // Calculate the text size.
        let textSize = getTextSize(headerText as String, font: nil, textAttributes: textAttributes)
        
        // Determine the offset to the right side.
        let offsetX: CGFloat = 20.0
        
        // Specify the point that the text drawing should start from.
        let pointX = headerRect.size.width - textSize.width - offsetX
        let pointY = headerRect.size.height/2 - textSize.height/2
        
        // Draw the header text.
        headerText.drawAtPoint(CGPointMake(pointX, pointY), withAttributes: textAttributes)
    }
    
    
    override func drawFooterForPageAtIndex(pageIndex: Int, inRect footerRect: CGRect) {
        let footerText: NSString = "Thank you!"
        
        let font = UIFont(name: "Noteworthy-Bold", size: 14.0)
        let textSize = getTextSize(footerText as String, font: font!)
        
        let centerX = footerRect.size.width/2 - textSize.width/2
        let centerY = footerRect.origin.y + self.footerHeight/2 - textSize.height/2
        let attributes = [NSFontAttributeName: font!, NSForegroundColorAttributeName: UIColor(red: 205.0/255.0, green: 205.0/255.0, blue: 205.0/255, alpha: 1.0)]
        
        footerText.drawAtPoint(CGPointMake(centerX, centerY), withAttributes: attributes)
        
        
        // Draw a horizontal line.
        let lineOffsetX: CGFloat = 20.0
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(context, 205.0/255.0, 205.0/255.0, 205.0/255, 1.0)
        CGContextMoveToPoint(context, lineOffsetX, footerRect.origin.y)
        CGContextAddLineToPoint(context, footerRect.size.width - lineOffsetX, footerRect.origin.y)
        CGContextStrokePath(context)
    }
    
    
    
    func getTextSize(text: String, font: UIFont!, textAttributes: [String: AnyObject]! = nil) -> CGSize {
        let testLabel = UILabel(frame: CGRectMake(0.0, 0.0, self.paperRect.size.width, footerHeight))
        if let attributes = textAttributes {
            testLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        else {
            testLabel.text = text
            testLabel.font = font!
        }
        
        testLabel.sizeToFit()
        
        return testLabel.frame.size
    }
    
}
