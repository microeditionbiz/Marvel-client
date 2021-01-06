//
//  CharacterCell.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import UIKit

class CharacterCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func configure(with viewModel: CharacterViewModel) {
        self.thumbnailImageView.setImageURL(viewModel.thumbnail)
        self.nameLabel.text = viewModel.name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.nameLabel.font = .systemFont(ofSize: 24, weight: selected ? .heavy : .regular)
        
    }

}
