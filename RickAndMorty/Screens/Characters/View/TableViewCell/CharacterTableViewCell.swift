//
//  CharacterTableViewCell.swift
//  RickAndMorty
//
//  Created by Rohit on 21/01/25.
//

import UIKit

class CharacterTableViewCell: UITableViewCell {

    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var episodeNumberLabel: UILabel!
    @IBOutlet weak var speciesLabel: UILabel!
    
    static let identifier = "CharacterTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius  = 6
        contentView.layer.masksToBounds = true
        
        characterImage.layer.cornerRadius   = 6
        characterImage.layer.masksToBounds  = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCell(with character: Character) {
        characterImage.downloadImage(fromURL: character.image)
        characterNameLabel.text = character.name
        episodeNumberLabel.text = "\(Constants.string.episodes): \(character.episode.count)"
        speciesLabel.text       = character.species
    }
    
}
