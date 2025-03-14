//
//  ViewController.swift
//  RickAndMartin
//
//  Created by Rohit on 17/01/25.
//

import UIKit

enum Section {
    case main
}

class CharacterVC: BaseViewController {
    
    var collectionViewdataSource: UICollectionViewDiffableDataSource<Section, Character>!
    var tableViewDataSource: UITableViewDiffableDataSource<Section, Character>!
    
    let characterCollectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let characterTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let viewModel = CharacterViewModel()
    private var characters: [Character] = []
    private var filteredCharacters: [Character] = []
    private var isTableViewVisible = true
    private var isLoadingRequest = false
    private var isFilterList = false
    private var page = 1
    private var filterPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        configureNavigationBar()
        configureSearchBar()
        configureCollectionView()
        configureTableView()
        fetchCharacters()
        configureDataSource()
        toggleList(isTableViewVisible)
    }
    
    func configureNavigationBar() {
        title = Constants.titleCharacters
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.grid.2x2"), style: .plain, target: self, action: #selector(rightBarButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(resource: .accent)
    }
    
    private func configureSearchBar() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater   = self
        searchController.searchBar.delegate     = self
        searchController.searchBar.placeholder  = "Find your favorite character..."
        navigationItem.searchController  = searchController
    }

    private func configureCollectionView() {
        characterCollectionView.delegate = self
        characterCollectionView.collectionViewLayout = viewModel.createCollectionViewLayout()
        characterCollectionView.register(UINib(nibName: CharacterCell.indentifier, bundle: nil), forCellWithReuseIdentifier: CharacterCell.indentifier)
        viewModel.setupView(characterCollectionView, on: view)
    }
    
    private func configureTableView() {
        characterTableView.delegate = self
        characterTableView.register(UINib(nibName: CharacterTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: CharacterTableViewCell.identifier)
        viewModel.setupView(characterTableView, on: view)
    }
    
    private func configureDataSource() {
        collectionViewdataSource = viewModel.getCollectionViewDataSource(for: characterCollectionView)
        tableViewDataSource = viewModel.getTableViewDataSource(for: characterTableView)
    }
    
    private func fetchCharacters() {
        isLoadingRequest = true
        showLoadingIndicator()
        viewModel.fetchCharacters(page) { [weak self] characters in
            guard let self else { return }
            
            hideLoadingIndicator()
            self.characters.append(contentsOf: characters)
            updateData(with: self.characters)
            page += 1
            self.isLoadingRequest = false
        }
    }
    
    @objc private func fetchCharacters(by name: String) {
        isLoadingRequest = true
        showLoadingIndicator()
        viewModel.fetchCharacters(by: name, filterPage) { [weak self] filteredCharacters in
            guard let self else { return }
            
            hideLoadingIndicator()
            self.filteredCharacters.append(contentsOf: filteredCharacters)
            updateData(with: self.filteredCharacters)
            filterPage += 1
            self.isLoadingRequest = false
        }
    }
    
    private func updateData(with currentCharacters: [Character]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Character>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(currentCharacters, toSection: .main)
        
        if isTableViewVisible {
            tableViewDataSource.apply(snapshot, animatingDifferences: true)
        } else {
            collectionViewdataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    func toggleList(_ isTableView: Bool) {
        if isTableView {
            characterCollectionView.removeFromSuperview()
            view.addSubview(characterTableView)
            
            viewModel.setupView(characterTableView, on: view)
        } else {
            characterTableView.removeFromSuperview()
            view.addSubview(characterCollectionView)
            
            viewModel.setupView(characterCollectionView, on: view)
        }
    }
    
    // MARK: - Button actions
    
    @objc func rightBarButtonTapped() {
        isTableViewVisible.toggle()
        navigationItem.rightBarButtonItem?.image = isTableViewVisible ? UIImage(systemName: "rectangle.grid.2x2") : UIImage(systemName: "list.bullet")
        toggleList(isTableViewVisible)
        updateData(with: characters)
    }
}

// MARK: - UICollectionViewDelegate
extension CharacterVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCharacter = isFilterList ? filteredCharacters[indexPath.row] : characters[indexPath.row]
        let detailVC = viewModel.getDetailVC(with: selectedCharacter)
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension CharacterVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCharacter = isFilterList ? filteredCharacters[indexPath.row] : characters[indexPath.row]
        let detailVC = viewModel.getDetailVC(with: selectedCharacter)
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate, UISearchResultsUpdating
extension CharacterVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) { }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filteredCharacters = []
        isFilterList = true
        if let searchTerm = searchBar.text, !searchTerm.isEmpty {
            fetchCharacters(by: searchTerm)
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredCharacters = []
        filterPage = 1
        isFilterList = false
        updateData(with: characters)
    }
}

// MARK: - Supporting methods
extension CharacterVC {
    private func showLoadingIndicator() {
        showLaodingView()
    }
    
    private func hideLoadingIndicator() {
        dismissLoadingView()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY         = scrollView.contentOffset.y
        let contentHeight   = scrollView.contentSize.height
        let height          = scrollView.frame.height
        
        if offsetY > contentHeight - height - 120 {
            guard !isLoadingRequest else { return }
            fetchCharacters()
        }
    }
}

// MARK: - UITabBarControllerDelegate
extension CharacterVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        
        if tabBarIndex == 0 {
            isTableViewVisible ? characterTableView.setContentOffset(CGPointZero, animated: true) : characterCollectionView.setContentOffset(CGPointZero, animated: true)
        }
    }
}
