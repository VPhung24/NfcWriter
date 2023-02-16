//
//  VivUIKitExtensionsUserDefaultsContactTests.swift
//  NfcWriterTests
//
//  Created by Vivian Phung on 11/22/22.
//

import XCTest
import Contacts
@testable import NfcWriter

final class VivUIKitExtensionsUserDefaultsContactTests: XCTestCase {
    func testContactUserDefaultsExtension() throws {
        let contact = CNMutableContact()
        contact.givenName = "TestGivenName"

        UserDefaults.standard.set(contact, forKey: "Contact")

        let retrivedContact = UserDefaults.standard.contact(forKey: "Contact")
        XCTAssertEqual(contact, retrivedContact)
    }
}
