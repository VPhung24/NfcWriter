//
//  RewriteViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/19/22.
//

import UIKit

class RewriteViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "read", style: .done, target: self, action: #selector(read))
    }
    
    @objc func read() {
        
    }
}

