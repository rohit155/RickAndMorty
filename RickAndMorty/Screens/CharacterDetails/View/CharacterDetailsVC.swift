//
//  CharacterDetailsVC.swift
//  RickAndMorty
//
//  Created by Rohit on 22/01/25.
//

import UIKit

class CharacterDetailsVC: UITableViewController {

    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var characterStatusLabel: UILabel!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    var character: Character!
    var isFromFavouriteScreen = false
    private let viewModel = CharacterDetailViewModel()
    private var episodes: [EpisodeDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        configureTableView()
        fetchEpisodes()
    }
    
    func configureVC() {
        title = character.name
        characterImageView.layer.cornerRadius = 12
        characterImageView.downloadImage(fromURL: character.image)
        characterStatusLabel.text   = character.status
        speciesLabel.text           = character.species
        genderLabel.text            = character.gender
        locationLabel.text          = character.location.name
        statusImageView.tintColor   = character.status == Constants.characterStatus.alive ? .green : .red
        
        if !isFromFavouriteScreen {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonAction))
        }
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Identifier.cell)
    }
    
    func fetchEpisodes() {
        viewModel.fetchEpisodes(with: character.episode) { [weak self] episodes in
            self?.episodes.append(contentsOf: episodes)
            if let episodesCount = self?.episodes.count, episodesCount > 0 {
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc func rightBarButtonAction() {
        PersistenceManager.updateWith(favourite: character, actionType: .add) { [weak self] error in
            
            guard let self = self else { return }
            
            guard error != nil else {
                showToast(message: Constants.characterFavourited, position: .top)
                return
            }
            
            showToast(message: Constants.characterAlreayFavourited, position: .top, bgColor: UIColor.systemOrange)
        }
    }
}

extension CharacterDetailsVC {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "EPISODES (\(character.episode.count))"
        }
        
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return episodes.isEmpty ? 1 : episodes.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            
            guard !episodes.isEmpty else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.cell) ?? UITableViewCell()
                var content = cell.defaultContentConfiguration()
                content.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                content.text = Constants.loading
                content.textProperties.alignment = .center
                
                cell.contentView.layoutMargins.bottom = 20
                cell.contentConfiguration = content
                
                return cell
            }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.cell) else {
                return UITableViewCell()
            }
            
            let info = episodes[indexPath.row]
            
            var content = cell.defaultContentConfiguration()
            content.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            content.secondaryTextProperties.font =  UIFont.systemFont(ofSize: 12, weight: .regular)
            content.secondaryTextProperties.color = .secondaryLabel
            content.textToSecondaryTextVerticalPadding = 2
            
            content.text = info.episode + " - " + info.name
            content.secondaryText = info.airDate
            cell.contentConfiguration = content
            
            return cell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return UITableView.automaticDimension
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}
