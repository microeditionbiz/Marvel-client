//
//  CharacterDetailsFooterView.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 06/01/2021.
//

import UIKit

class CharacterDetailsFooterView: UICollectionReusableView {
    
    let loadNextPageView: LoadNextPageView = {
        let view = LoadNextPageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        self.addSubview(loadNextPageView)
        loadNextPageView.edgesToSuperview()
    }

}
