//
//  CharacterDetailsHeaderView.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 06/01/2021.
//

import UIKit

class CharacterDetailsHeaderView: UICollectionReusableView {

    let stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()

    let detailsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()


    let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        addSubview(stackView)
        stackView.edgesToSuperviewMarings()

        stackView.addArrangedSubview(detailsLabel)
        stackView.addArrangedSubview(imageView)
    }

    func configure(with character: CharacterViewModel) {
        imageView.setImageURL(character.image)

        character.details.nilIfEmpty.do({ details in
            self.detailsLabel.isHidden = false
            self.detailsLabel.text = details
        }, otherwise: {
            self.detailsLabel.isHidden = true
        })
    }
}
