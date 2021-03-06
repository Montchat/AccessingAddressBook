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
    
    typealias Name = String
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
                    print("error \(error)")
                    
                } else {
                    
                        let allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
                        let nPeople = ABAddressBookGetPersonCount(addressBook)
                    
                    for i in 0 ..< nPeople {
                        
                        let ref: ABRecordRef = Unmanaged<ABRecordRef>.fromOpaque(COpaquePointer(CFArrayGetValueAtIndex(allPeople, i))).takeUnretainedValue()
                        
                        let contact:Contact!
                        
                        let firstName: Name?
                        let lastName:Name?
                        var phoneNumbers:[PhoneNumber]?
                        var emails:[Email]?
                        
                        if ABRecordCopyValue(ref, kABPersonFirstNameProperty) == nil { continue } else {
                            
                            guard let _firstName: Name = ABRecordCopyValue(ref, kABPersonFirstNameProperty).takeUnretainedValue() as? Name else { return }
                            firstName = _firstName

                        }
                        
                        if ABRecordCopyValue(ref, kABPersonPhoneProperty) == nil { // if we don't have any phoneNumbers
                            phoneNumbers = []
                            
                        } else {
                            
                            phoneNumbers = []
                            
                            let multiValueRef: ABMultiValueRef = ABRecordCopyValue(ref, kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValueRef
                            
                            let countOfPhones = ABMultiValueGetCount(multiValueRef)
                            
                            for index in 0..<countOfPhones {
                                
                                print("count \(index)")
                                
                                let unmanagedPhone = ABMultiValueCopyValueAtIndex(multiValueRef, index)
                                
                                let phoneNumber : NSString = unmanagedPhone.takeUnretainedValue() as! NSString
                                let _phoneNumber = phoneNumber as String
                                
                                phoneNumbers?.append(_phoneNumber)
                                
                            }
                            
                        }
                        
                        if ABRecordCopyValue(ref, kABPersonEmailProperty) == nil {
                            emails = [ ]
                        } else {
                            
                            emails = []
                            
                            let multiValueRef: ABMultiValueRef = ABRecordCopyValue(ref, kABPersonEmailProperty).takeUnretainedValue() as ABMultiValueRef
                            
                            let countOfEmails = ABMultiValueGetCount(multiValueRef)
                            
                            for index in 0..<countOfEmails {
                                
                                let unmanagedEmail = ABMultiValueCopyValueAtIndex(multiValueRef, index)
                                
                                let email : NSString = unmanagedEmail.takeUnretainedValue() as! NSString
                                let _email = email as String
                                
                                emails?.append(_email)
                                
                            }
                            
                        }
                        
                        if ABRecordCopyValue(ref, kABPersonLastNameProperty) == nil {
                            contact = Contact(name: firstName, phoneNumbers: phoneNumbers, emails: emails)
                            dispatch_async(dispatch_get_main_queue(), {
                                self.contacts.append(contact)
                                
                            })
                            
                            continue
                            
                        } else {
                            
                            guard let _lastName: Name = ABRecordCopyValue(ref, kABPersonLastNameProperty).takeUnretainedValue() as? Name else { return }
                            lastName = _lastName
                            
                        }
                        
                        guard let _firstName = firstName else { return }
                        guard let _lastName = lastName else { return }
                        
                        contact = Contact(name: _firstName + " " + _lastName, phoneNumbers: phoneNumbers, emails: emails)
                        
                        dispatch_async(dispatch_get_main_queue(), { self.contacts.append(contact)
                            
                        })
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { self.tableView.reloadData()
                        
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
        
}

class Contact {
    
    typealias Name = String
    typealias PhoneNumber = String
    typealias Email = String
    
    var name:Name?
    var phoneNumbers:[PhoneNumber]?
    var emails:[Email]?
    
    init(name:Name?, phoneNumbers: [PhoneNumber]?, emails: [Email]?) {
        self.name = name
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
    
}

class ContactsCell : UITableViewCell {
    
    let contact:Contact!
    
    init(contact: Contact) {
        
        self.contact = contact
        
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        textLabel?.text = contact.name
        
        guard let phoneNumbers = contact.phoneNumbers else { return }
        if phoneNumbers.count != 0 {
            detailTextLabel?.text = phoneNumbers[0]
            
        }
        
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



