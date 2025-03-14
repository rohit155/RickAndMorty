//
//  FavouriteCharacterVC.swift
//  RickAndMorty
//
//  Created by Rohit on 21/02/25.
//

import UIKit

class FavouriteCharacterVC: UIViewController {
    
    var tableViewDataSource: UITableViewDiffableDataSource<Section, Character>!
    
    let characterTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let noDataLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.noCharterFavourited
        label.textColor = UIColor(resource: .accent)
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private var characters = [Character]()
    private let viewModel = CharacterViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.titleFavourites
        setupTableView()
        setupLabel()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getSavedData()
    }
    
    private func setupTableView() {
        view.addSubview(characterTableView)
        NSLayoutConstraint.activate([
            characterTableView.topAnchor.constraint(equalTo: view.topAnchor),
            characterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            characterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            characterTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        characterTableView.delegate = self
        characterTableView.register(UINib(nibName: CharacterTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: CharacterTableViewCell.identifier)
        
        tableViewDataSource = UITableViewDiffableDataSource(tableView: characterTableView, cellProvider: { [weak self] tableView, indexPath, character in
            
            guard let cell = self?.characterTableView.dequeueReusableCell(withIdentifier: CharacterTableViewCell.identifier, for: indexPath) as? CharacterTableViewCell else {
                return UITableViewCell()
            }
            cell.setupCell(with: character)
            return cell
        })
    }
    
    private func setupLabel() {
        view.addSubview(noDataLabel)
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noDataLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    private func getSavedData() {
        PersistenceManager.retrieveFavourites { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let favourites):
                if favourites.isEmpty {
                    noDataLabel.isHidden = false
                    characterTableView.isHidden = true
                } else {
                    self.characters = favourites
                    noDataLabel.isHidden = true
                    characterTableView.isHidden = false
                    updateTableView(with: self.characters)
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func updateTableView(with characters: [Character]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Character>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(characters, toSection: .main)
        
        tableViewDataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension FavouriteCharacterVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selecterCharacter = characters[indexPath.row]
        let detailVC = viewModel.getDetailVC(with: selecterCharacter, isFromFavouriteScreen: true)
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }
            
            let deleteCharacter = self.characters[indexPath.row]
            
            PersistenceManager.updateWith(favourite: deleteCharacter, actionType: .remove) { error in
                
                guard let error = error else {
                    self.characters.remove(at: indexPath.row)
                    self.updateTableView(with: self.characters)
                    return
                }
                
                print("Failed \(error.localizedDescription)")
            }
            self.getSavedData()
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}
