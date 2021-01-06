//
//  ComicCell.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 06/01/2021.
//

import UIKit

class ComicCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    func configure(with comic: ComicViewModel) {
        titleLabel.text = comic.title
        imageView.setImageURL(comic.thumbnail)
    }
}
