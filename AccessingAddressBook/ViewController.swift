//
//  ViewController.swift
//  AccessingAddressBook
//
//  Created by Joe E. on 6/30/16.
//  Copyright © 2016 Montchat. All rights reserved.
//

import UIKit
import AddressBook

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



