//
//  ViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/17/22.
//

import UIKit

class SearchViewController: UIViewController {

    let searchBar: UISearchController = {
        let sb = UISearchController()
        sb.searchBar.placeholder = "twitter handle"
        sb.searchBar.searchBarStyle = .prominent
        return sb
    }()
    
    let searchTableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "twitter")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "find ur twitter"
        self.view.backgroundColor = .systemBackground
        
        searchBar.searchResultsUpdater = self
        navigationItem.searchController = searchBar
        
        self.view.addSubview(searchTableView)
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        NSLayoutConstraint.activate([
            searchTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            searchTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}

extension SearchViewController: UITableViewDelegate {
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "twitter", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = "test name"
        content.secondaryText = "test handle"
        content.image = UIImage(systemName: "star")
        cell.contentConfiguration = content
        
        return cell
    }
}
