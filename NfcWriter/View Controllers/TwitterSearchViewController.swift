//
//  TwitterSearchViewController.swift
//  NfcWriter
//
//  Created by Vivian Phung on 10/17/22.
//

import UIKit

class TwitterSearchViewController: UIViewController {

    private var twitterHandles: [TwitterProfileModel] = []
    private lazy var dataSource = initDataSource()
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TwitterProfileModel>

    let searchBarController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "search for twitter handle"
        searchController.searchBar.accessibilityTraits = .searchField
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.backgroundColor = .systemBackground

        // dynamic text sizing per settings
        searchController.searchBar.searchTextField.adjustsFontForContentSizeCategory = true

        // remove predictive text in keyboard
        searchController.searchBar.searchTextField.autocorrectionType = .no
        searchController.searchBar.searchTextField.spellCheckingType = .no

        // accessibility enable clear button tap
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()

    let searchTableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "twitter")

        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemBackground
        tableView.backgroundView = backgroundView
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = .systemBackground

        searchBarController.searchResultsUpdater = self
        searchBarController.searchBar.delegate = self

        self.view.addSubview(searchTableView)

        searchTableView.delegate = self
        searchTableView.dataSource = dataSource
        searchTableView.tableHeaderView = searchBarController.searchBar

        // hacky way of getting "x" clear button action
        let searchTextField = searchBarController.searchBar.searchTextField
        if let clearButton = searchTextField.value(forKey: "_clearButton") as? UIButton {
            clearButton.addTarget(self, action: #selector(clearSearch), for: .touchUpInside)
        }

        NSLayoutConstraint.activate([
            searchTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            searchTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        self.view.accessibilityElements = [searchBarController, searchTableView]
    }

    // MARK: - UITableViewDiffableDataSource
    func initDataSource() -> DataSource {
        let dataSource = DataSource(tableView: searchTableView, cellProvider: { (tableView, indexPath, twitterHandle: TwitterProfileModel) -> UITableViewCell? in
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "twitter", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = twitterHandle.name
            content.secondaryText = twitterHandle.username
            if twitterHandle.image == nil {
                self.getProfileImageForTwitterProfile(twitterHandle: twitterHandle)
            } else {
                content.image = twitterHandle.image
                // default profile photo size "normal" is 48x48. circle corner radius 48/2
                content.imageProperties.maximumSize = CGSize(width: 48, height: 48)
                content.imageProperties.cornerRadius = 24
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

    fileprivate func getProfileImageForTwitterProfile(twitterHandle: TwitterProfileModel) {
        APIManager.shared.getProfileImage(twitterHandleModel: twitterHandle) { updatedTwitterModelWithImage, _ in
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

    @objc private func clearSearch() {
        self.twitterHandles = []
        self.applySnapshot(animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension TwitterSearchViewController: UISearchResultsUpdating {
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
extension TwitterSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBarController.isActive = false
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(TwitterNFCTaggingViewController(twitterProfile: self.twitterHandles[indexPath.row]), animated: true)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
}

extension TwitterSearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearSearch()
    }
}
