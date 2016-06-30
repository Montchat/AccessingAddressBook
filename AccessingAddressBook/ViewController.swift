//
//  ViewController.swift
//  AccessingAddressBook
//
//  Created by Joe E. on 6/30/16.
//  Copyright © 2016 Montchat. All rights reserved.
//

import UIKit
import AddressBook

class ViewController: UIViewController {
    
    typealias AddressBook = ABAddressBook
    
    var addressBook:AddressBook!
    
    func createAddressBook() -> Bool {
        if self.addressBook != nil {
            return true
        }
        var err : Unmanaged<CFError>? = nil
        let addressBook : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if addressBook == nil {
            print(err)
            self.addressBook = nil
            return false
        }
        self.addressBook = addressBook
        return true
    }
    
    func determineStatus() -> Bool {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .Authorized:
            return self.createAddressBook()
        case .NotDetermined:
            var ok = false
            
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted:Bool, err:CFError!) in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted {
                        ok = self.createAddressBook()
                    }
                }
            }
            if ok == true {
                return true
            }
            self.addressBook = nil
            return false
        case .Restricted:
            self.addressBook = nil
            return false
        case .Denied:
            self.addressBook = nil
            return false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        determineStatus()
        
        print("addressBook \(addressBook)")
    }

}

