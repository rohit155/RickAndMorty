//
//  CharacterCell.swift
//  RickAndMartin
//
//  Created by Rohit on 17/01/25.
//

import UIKit

class CharacterCell: UICollectionViewCell {

    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var episodesNumberLabel: UILabel!
    @IBOutlet weak var characterImageView: UIImageView!
    
    static let indentifier = "CharacterCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius  = 6
        contentView.layer.masksToBounds = true
        
        characterImageView.layer.cornerRadius   = 6
        characterImageView.layer.masksToBounds  = true
    }
    
    func setupCell(with character: Character) {
        characterImageView.downloadImage(fromURL: character.image)
        characterNameLabel.text = character.name
        episodesNumberLabel.text = "\(Constants.string.episodes): \(character.episode.count)"
    }
}
