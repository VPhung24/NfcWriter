//
//  UserDefaults+Extensions.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/27/22.
//

import Foundation
import Contacts

extension UserDefaults {
    /**
     Sets the value of the specified default key to the specified contact value.
     */
    func set(_ value: CNContact, forKey defaultName: String) {
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: defaultName)
        } catch {
            print("error setting contact as user default")
        }
    }

    /**
     returns the contact associated with the specified key
     */
    func contact(forKey defaultName: String) -> CNContact? {
        if let data = UserDefaults.standard.data(forKey: defaultName) {
            do {
                if let loadedContact = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [CNContact.self], from: data) as? CNContact {
                    return loadedContact
                }
            } catch {
                print("error decoding contact from user defaults")
            }
        }
        return nil
    }
}
