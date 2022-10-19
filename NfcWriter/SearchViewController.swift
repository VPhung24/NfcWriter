//
//  ViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/17/22.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var twitterHandles: [TwitterHandleModel] = []
    private lazy var dataSource = initDataSource()
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TwitterHandleModel>
    
    let searchBar: UISearchController = {
        let sb = UISearchController()
        sb.searchBar.placeholder = "search for twitter handle"
        sb.searchBar.accessibilityTraits = .searchField
        
        // dynamic text sizing per settings
        sb.searchBar.searchTextField.adjustsFontForContentSizeCategory = true
        
        // remove predictive text in keyboard
        sb.searchBar.searchTextField.autocorrectionType = .no
        sb.searchBar.searchTextField.spellCheckingType = .no
        
        // accessibility enable clear button tap
        sb.obscuresBackgroundDuringPresentation = false
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
        searchTableView.dataSource = dataSource
        
        NSLayoutConstraint.activate([
            searchTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            searchTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        self.view.accessibilityElements = [self.title, searchBar, searchTableView]
    }
    
    // MARK: - UITableViewDiffableDataSource
    func initDataSource() -> DataSource {
        let dataSource = DataSource(tableView: searchTableView, cellProvider: { (tableView, indexPath, twitterHandle: TwitterHandleModel) -> UITableViewCell? in
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "twitter", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = twitterHandle.name
            content.secondaryText = twitterHandle.username
            if twitterHandle.image == nil {
                self.getProfileImageForTwitterProfile(twitterHandle: twitterHandle)
            } else {
                content.image = twitterHandle.image
            }
            cell.contentConfiguration = content
            cell.accessibilityTraits = .button
            cell.accessibilityLabel = "handle \(twitterHandle.username) with account name \(twitterHandle.name)"
            cell.accessibilityHint = "tap to tag user"
            return cell
        })
        return dataSource
    }
    
    // MARK: - NSDiffableDataSourceSnapshot
    func applySnapshot(animated: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.twitter])
        snapshot.appendItems(twitterHandles)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    fileprivate func getProfileImageForTwitterProfile(twitterHandle: TwitterHandleModel) {
        APIManager.shared.getProfileImage(twitterHandleModel: twitterHandle) { updatedTwitterModelWithImage, error in
            guard let updatedModel = updatedTwitterModelWithImage else {
                return
            }
            var currentSnapshot = self.dataSource.snapshot()
            if let datasourceIndex = currentSnapshot.indexOfItem(updatedModel) {
                let item = self.twitterHandles[datasourceIndex]
                item.image = updatedModel.image
                currentSnapshot.reloadItems([item])
                self.dataSource.apply(currentSnapshot, animatingDifferences: true)
            }
        }
    }
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchBarText = searchController.searchBar.text {
            APIManager.shared.searchforTwitterHandle(forString: searchBarText) { [weak self] (response, error) in
                guard error == nil, let response = response else {
                    print("apiRequest error: ", error ?? "nothing")
                    return
                }
                self?.twitterHandles = response
                self?.applySnapshot(animated: true)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(TagNFCViewController(twitterProfile: self.twitterHandles[indexPath.row]), animated: false)
    }
}
