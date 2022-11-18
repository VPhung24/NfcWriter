//
//  FirebaseHelpers.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/27/22.
//

import Foundation
import FirebaseCore
import FirebaseStorage

// Points to the root reference
let storageRef = Storage.storage().reference()

// Points to "images"
let imagesRef = storageRef.child("images")

// Points to "images/space.jpg"
// Note that you can use variables to create child values
let fileName = "space.jpg"
let spaceRef = imagesRef.child(fileName)

// File path is "images/space.jpg"
let path = spaceRef.fullPath

// File name is "space.jpg"
let name = spaceRef.name

// Points to "images"
let images = spaceRef.parent()
