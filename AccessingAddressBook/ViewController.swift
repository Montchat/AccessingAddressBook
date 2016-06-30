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
            print("authorized")
            
            var error: Unmanaged<CFError>?
            guard let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue() else { print(error?.takeRetainedValue()) ; return }
            
            print("addressBook \(addressBook)")
            
            ABAddressBookRequestAccessWithCompletion(addressBook, { (granted, error) in
                if error != nil {
                    print("we have an error \(error)")
                    
                } else {
                    
                        let allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
                        let nPeople = ABAddressBookGetPersonCount(addressBook)
                    
                    for i in 0 ... nPeople {
                        let ref = CFArrayGetValueAtIndex(allPeople, i)
                        print("ref \(ref)")
                        
                    }
                }
            })

        
        
//                    for ( int i = 0; i < nPeople; i++ )
//                    {
//                        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
//                        ...
//                    }


                    
//                    let contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
//                    for record:ABRecordRef in contactList {
                    
//                        let contactPerson: ABRecordRef = record
//                        print("contactPerson \(contactPerson)")
                    
//                        if let contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as? String {
//                            print("contactName \(contactName)")
//                            
//                        }
                    
//                        let emailArray:ABMultiValueRef = extractABEmailRef(ABRecordCopyValue(contactPerson, kABPersonEmailProperty))
//                        
//                        for (var j = 0; j < ABMultiValueGetCount(emailArray); ++j)
//                        {
//                            var emailAdd = ABMultiValueCopyValueAtIndex(emailArray, j)
//                            var myString = extractABEmailAddress(emailAdd)
//                            println("email: \(myString)")
//                        }
//                        
//                        
//                    }
//
//                    print("people \(people)")
//                    
//                    for person in people {
//                        print(person)
//                    }
                    
//            }
//        
//            })
    
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
    typealias Number = Int
    
    var number:Int?
    var name:Name?
    
    init(name:Name?, number: Number?) {
        self.name = name
        self.number = number
    }
    
}


class ContactsCell : UITableViewCell {
    
    let contact:Contact!
    
    init(contact: Contact) {
        
        self.contact = contact
        
        super.init(style: .Default, reuseIdentifier: "cell")
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



