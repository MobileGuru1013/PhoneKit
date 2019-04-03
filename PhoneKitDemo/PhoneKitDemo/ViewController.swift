//
//  ViewController.swift
//  PhoneKitDemo
//
//  Created by Bruce Colby on 6/20/18.
//  Copyright © 2018 Bruce Colby. All rights reserved.
//

import UIKit
import PhoneKit

class ViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var numbersTextField: PhoneTextField!
    @IBOutlet weak var elegantTextField: PhoneTextField!
    @IBOutlet weak var customTextField: PhoneTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
    }
}

// MARK: - Setup
extension ViewController {
    func setupTextFields() {
        numbersTextField.phoneNumber = .numbers
        elegantTextField.phoneNumber = .elegant
        customTextField.phoneNumber = .custom("[216] - 8888-319")
    }
}

class PhoneTextField: UITextField, UITextFieldDelegate {
    var phoneNumber: PhoneNumber?
    var direction: PhoneNumberDirection = .forward
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.delegate = self
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                direction = .backward
            } else {
                direction = .forward
            }
        }
        
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let phoneNumber = phoneNumber else { return }
        textField.text = phoneNumber.format(text: textField.text ?? "", direction: direction)
        
        if validate(text: textField.text ?? "") {
            self.backgroundColor = #colorLiteral(red: 0.9019607843, green: 1, blue: 1, alpha: 1)
            self.layer.borderColor = #colorLiteral(red: 0, green: 0.6588235294, blue: 1, alpha: 1)
        } else {
            self.backgroundColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0.6431372549, alpha: 1)
            self.layer.borderColor = #colorLiteral(red: 0.9098039216, green: 0.2549019608, blue: 0.09411764706, alpha: 1)
        }
    }
    
    func validate(text: String) -> Bool {
        guard let phoneNumber = phoneNumber else { return false }
        return phoneNumber.validate(text: text)
    }
}

