//
//  AddItemViewController.swift
//  Print2PDF
//
//  Created by Gabriel Theodoropoulos on 14/06/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtItemDescription: UITextField!
    
    @IBOutlet weak var txtPrice: UITextField!
    
    
    var currentTextfield: UITextField!
    
    var saveCompletionHandler: ((_ itemDescription: String, _ price: String) -> Void)!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set self as the delegate of the textfields.
        txtItemDescription.delegate = self
        txtPrice.delegate = self
        
        // Add a tap gesture recognizer to the view to dismiss the keyboard.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
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

    
    // MARK: Custom Methods
    
    func dismissKeyboard() {
        if currentTextfield != nil {
            currentTextfield.resignFirstResponder()
            currentTextfield = nil
        }
    }
    
    
    func presentAddItemViewControllerInViewController(originatingViewController: UIViewController, saveItemCompletionHandler: @escaping (_ itemDescription: String, _ price: String) -> Void) {
        saveCompletionHandler = saveItemCompletionHandler
        originatingViewController.navigationController?.pushViewController(self, animated: true)
    }
    
    
    // MARK: IBAction Methods
    
    @IBAction func saveItem(_ sender: AnyObject) {
        if (txtItemDescription.text?.characters.count)! > 0 &&
            (txtPrice.text?.characters.count)! > 0 {
            
            if saveCompletionHandler != nil {
                // Call the save completion handler to pass the item description and the price back to the CreatorViewController object.
                
                saveCompletionHandler(_ : txtItemDescription.text!, _: txtPrice.text!)
                
                // Pop the view controller.
                _ = navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextfield = textField
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtItemDescription {
            textField.resignFirstResponder()
            txtPrice.becomeFirstResponder()
        }
        
        return true
    }
    
}
