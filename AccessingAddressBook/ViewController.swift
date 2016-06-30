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
    
override func viewDidLoad() {
    super.viewDidLoad()
    
    checkForAddressBookPermission()
    
    }
    
    private func checkForAddressBookPermission() {
        
        let status:ABAuthorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        switch status {
        case .Authorized:
            print("authorized")
            
            var error: Unmanaged<CFError>?
            guard let addressBook: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue() else { print(error?.takeRetainedValue()) ; return }
            
            print("addressBook \(addressBook)")
            
            ABAddressBookRequestAccessWithCompletion(addressBook, { (granted, error) in
                if error != nil {
                    print("we have an error \(error)")
                    
                } else {
                    print("working")
                    let people = ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeRetainedValue()
                    print("people \(people)")
                    
//                    for person in people {
//                        print("person \(person)")
//                        
//                    }
                    
                }
                
            })
            
        case .Denied:
            //present alert that permisson was denied 
            print("denied")
            
        case .NotDetermined:
            print("not determined")
            
        case .Restricted:
            print("restricted")
            
            //present alert that permission is restricted
            
        }
    
    }
    
}

