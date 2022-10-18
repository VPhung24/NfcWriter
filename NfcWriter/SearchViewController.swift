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
        searchTableView.dataSource = dataSource
        
        NSLayoutConstraint.activate([
            searchTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            searchTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    // MARK: - UITableViewDiffableDataSource
    func initDataSource() -> DataSource {
        let dataSource = DataSource(tableView: searchTableView, cellProvider: { (tableView, indexPath, twitterHandle: TwitterHandleModel) -> UITableViewCell? in
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "twitter", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = twitterHandle.name
            content.secondaryText = twitterHandle.username
            if twitterHandle.image == nil {
                self.getProfileImageForTwitterProfile(twitterHandle)
            } else {
                content.image = twitterHandle.image
            }
            cell.contentConfiguration = content
            
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
    
    fileprivate func getProfileImageForTwitterProfile(_ twitterHandle: TwitterHandleModel) {
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
        let blankViewController = UIViewController()
        blankViewController.title = self.twitterHandles[indexPath.row].username
        
        self.navigationController?.pushViewController(blankViewController, animated: false)
    }
}
