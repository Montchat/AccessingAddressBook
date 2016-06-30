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
    typealias PhoneNumber = String
    typealias Email = String
    
    var addressBook:AddressBook!
    
    var contacts:[Contact]!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contacts = [ ]
        
        checkForAddressBookPermission()
        
        tableView.delegate = self ; tableView.dataSource = self
        
    }
    
    private func checkForAddressBookPermission() {
        
        let status:ABAuthorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        switch status {
        case .Authorized:
            
            var error: Unmanaged<CFError>?
            guard let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue() else { print(error?.takeRetainedValue()) ; return }
            
            ABAddressBookRequestAccessWithCompletion(addressBook, { (granted, error) in
                if error != nil {
                    
                } else {
                    
                        let allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
                        let nPeople = ABAddressBookGetPersonCount(addressBook)
                    
                    for i in 0 ... nPeople - 1 {
                        
                        let ref: ABRecordRef = Unmanaged<ABRecordRef>.fromOpaque(COpaquePointer(CFArrayGetValueAtIndex(allPeople, i))).takeUnretainedValue()
                        
                        let contact:Contact!
                        
                        let firstName: String?
                        let lastName:String?
                        let phoneNumber:PhoneNumber?
                        let email:Email?
                        
                        if ABRecordCopyValue(ref, kABPersonFirstNameProperty) == nil { continue } else {
                            
                            guard let _firstName: String = ABRecordCopyValue(ref, kABPersonFirstNameProperty).takeUnretainedValue() as? String else { return }
                            firstName = _firstName

                        }
                        
                        if ABRecordCopyValue(ref, kABPersonPhoneProperty) == nil {
                            phoneNumber = "No Number Found"
                            
                        } else {
                            
                            guard let _phoneNumber: String = ABRecordCopyValue(ref, kABPersonPhoneProperty).takeUnretainedValue() as? String else { return }
                            phoneNumber = _phoneNumber
                            
                        }
                        
                        if ABRecordCopyValue(ref, kABPersonLastNameProperty) == nil {
                            contact = Contact(name: firstName, number: 0)
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.contacts.append(contact)
                                
                            })
                            
                            continue
                            
                        } else {
                            
                            guard let _lastName: String = ABRecordCopyValue(ref, kABPersonLastNameProperty).takeUnretainedValue() as? String else { return }
                            lastName = _lastName
                            
                        }
                        
                        guard let _firstName = firstName else { return }
                        guard let _lastName = lastName else { return }
                        
                        contact = Contact(name: _firstName + " " + _lastName, number: 0)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.contacts.append(contact)
                            
                        })
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                    
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
    
    func extractABEmailRef (abEmailRef: Unmanaged<ABMultiValueRef>!) -> ABMultiValueRef? {
        if let ab = abEmailRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    func extractABEmailAddress (abEmailAddress: Unmanaged<AnyObject>!) -> String? {
        if let _ = abEmailAddress {
            return Unmanaged.fromOpaque(abEmailAddress.toOpaque()).takeUnretainedValue() as? CFStringRef as? String
        }
        return nil
    }
    
}

class Contact {
    
    typealias Name = String
    typealias PhoneNumber = String
    typealias Email = String
    
    var name:Name?
    var phoneNumber:PhoneNumber?
    var email:Email?
    
    init(name:Name?, phoneNumber: PhoneNumber?) {
        self.name = name
        self.phoneNumber = phoneNumber
    }
    
}


class ContactsCell : UITableViewCell {
    
    let contact:Contact!
    
    init(contact: Contact) {
        
        self.contact = contact
        
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        textLabel?.text = contact.name
        detailTextLabel?.text = "\(contact.number)"
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ViewController : UITableViewDelegate {
    
}

extension ViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = ContactsCell(contact: contacts[indexPath.row])
        return cell
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contacts.count
    }
    
}



