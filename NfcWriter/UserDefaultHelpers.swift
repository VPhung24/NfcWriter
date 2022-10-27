//
//  UserDefaultHelpers.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/27/22.
//

import Foundation
import Contacts

extension UserDefaults {
    func setContact(_ contact: CNContact, forKey key: String) {
        do {
            let data: Data = try CNContactVCardSerialization.data(with: [contact])
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("error setting contact as user default")
        }
    }
    
    func contact(forKey key: String) -> CNContact? {
        if let data: Data = UserDefaults.standard.object(forKey: key) as? Data {
            do {
                return try CNContactVCardSerialization.contacts(with: data).first
            } catch {
                print("error decoding contact")
            }
        }
        return nil
    }
}
