//
//  NFCTagManager.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/27/22.
//

import Foundation
import UIKit
import CoreNFC
import os

class NFCTagManager: NSObject, NFCNDEFReaderSessionDelegate {
    var readerSession: NFCNDEFReaderSession?
    var ndefMessage: NFCNDEFMessage?
    var url: String
    
    init(url: String) {
        self.url = url
        super.init()

        readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        readerSession?.alertMessage = "Hold your iPhone near a writable NFC tag to update."
        readerSession?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
    }
    
    func tagRemovalDetect(_ tag: NFCNDEFTag) {
        // In the tag removal procedure, you connect to the tag and query for
        // its availability. You restart RF polling when the tag becomes
        // unavailable; otherwise, wait for certain period of time and repeat
        // availability checking.
        self.readerSession?.connect(to: tag) { (error: Error?) in
            if error != nil || !tag.isAvailable {
                
                os_log("Restart polling")
                
                self.readerSession?.restartPolling()
                return
            }
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
                self.tagRemovalDetect(tag)
            })
        }
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        let textPayload = NFCNDEFPayload.wellKnownTypeTextPayload(
            string: "Twitter Tag",
            locale: Locale(identifier: "En")
        )
        let urlPayload = self.createURLPayload()
        ndefMessage = NFCNDEFMessage(records: [urlPayload!, textPayload!])
        os_log("MessageSize=%d", ndefMessage!.length)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = "More than 1 tags found. Please present only 1 tag."
            self.tagRemovalDetect(tags.first!)
            return
        }
        
        // You connect to the desired tag.
        let tag = tags.first!
        session.connect(to: tag) { (error: Error?) in
            if error != nil {
                session.restartPolling()
                return
            }
            
            // You then query the NDEF status of tag.
            tag.queryNDEFStatus() { (status: NFCNDEFStatus, capacity: Int, error: Error?) in
                if error != nil {
                    session.invalidate(errorMessage: "Fail to determine NDEF status.  Please try again.")
                    return
                }
                
                if status == .readOnly {
                    session.invalidate(errorMessage: "Tag is not writable.")
                } else if status == .readWrite {
                    if self.ndefMessage!.length > capacity {
                        session.invalidate(errorMessage: "Tag capacity is too small.  Minimum size requirement is \(self.ndefMessage!.length) bytes.")
                        return
                    }
                    
                    // When a tag is read-writable and has sufficient capacity,
                    // write an NDEF message to it.
                    tag.writeNDEF(self.ndefMessage!) { (error: Error?) in
                        if error != nil {
                            print(error?.localizedDescription ?? "error")
                            session.invalidate(errorMessage: "Update tag failed. Please try again.")
                        } else {
                            session.alertMessage = "Update success!"
                            session.invalidate()
                        }
                    }
                } else {
                    session.invalidate(errorMessage: "Tag is not NDEF formatted.")
                }
            }
        }
    }
    
    private func createURLPayload() -> NFCNDEFPayload? {
        let twitterURL = URL(string: url)
        
        os_log("url: %@", (twitterURL?.absoluteString)!)
        
        return NFCNDEFPayload.wellKnownTypeURIPayload(url: (twitterURL?.absoluteURL)!)
    }
}
