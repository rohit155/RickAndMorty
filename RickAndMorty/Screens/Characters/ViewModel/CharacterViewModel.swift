//
//  characterViewModel.swift
//  RickAndMartin
//
//  Created by Rohit on 18/01/25.
//

import UIKit

class CharacterViewModel {
    let apiManager = APIManager()
    
    func fetchCharacters(_ pageNumber: Int, completion: @escaping ([Character]) -> Void) {
        apiManager.getCharters(pageNumber: pageNumber) { result in
            switch result {
            case .success(let characters):
                DispatchQueue.main.async {
                    completion(characters.results)
                }
            case .failure(let failure):
                print("FAIl: \(failure)")
            }
        }
    }
    
    func fetchCharacters(by name: String, _ pageNumber: Int, completion: @escaping ([Character]) -> Void) {
        apiManager.getCharacters(by: name, pageNumber: pageNumber) { result in
            switch result {
            case .success(let characters):
                DispatchQueue.main.async {
                    completion(characters.results)
                }
            case .failure(let failure):
                print("FAIl: Charaters by name -> \(failure)")

            }
        }
    }
    
    func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let smallItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
        smallItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let smallGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .fractionalHeight(1)), repeatingSubitem: smallItem, count: 2)
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.6),
                heightDimension: .fractionalHeight(1))
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(0.40)), subitems: [item, smallGroup])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func getCollectionViewDataSource(for collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Character> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, character in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCell.indentifier, for: indexPath) as? CharacterCell else {
                return UICollectionViewCell()
            }
            cell.setupCell(with: character)
            return cell
        })
    }
    
    func getTableViewDataSource(for tableView: UITableView) -> UITableViewDiffableDataSource<Section, Character> {
        return UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, character in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CharacterTableViewCell.identifier, for: indexPath) as? CharacterTableViewCell else {
                return UITableViewCell()
            }
            cell.setupCell(with: character)
            return cell
        })
    }
    
    func getDetailVC(with selectedCharacter: Character, isFromFavouriteScreen: Bool = false) -> UIViewController {
        guard let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CharacterDetailsVC") as? CharacterDetailsVC else { return UIViewController() }
        
        detailVC.character = selectedCharacter
        detailVC.isFromFavouriteScreen = isFromFavouriteScreen
        
        return detailVC
    }
    
    func setupView(_ scrollView: UIScrollView, on view: UIView) {
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}
