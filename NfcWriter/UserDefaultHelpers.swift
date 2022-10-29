//
//  UserDefaultHelpers.swift
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
            let data: Data = try CNContactVCardSerialization.data(with: [value])
            UserDefaults.standard.set(data.first, forKey: defaultName)
        } catch {
            print("error setting contact as user default")
        }
    }

    /**
     returns the contact associated with the specified key
     */
    func contact(forKey defaultName: String) -> CNContact? {
        if let data: Data = UserDefaults.standard.object(forKey: defaultName) as? Data {
            do {
                return try CNContactVCardSerialization.contacts(with: data).first
            } catch {
                print("error decoding contact from user defaults")
            }
        }
        return nil
    }
}
