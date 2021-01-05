//
//  ViewControllerBuilder.swift
//  SwiftRSSReader
//
//  Created by Pablo Ezequiel Romero Giovannoni on 17/07/2020.
//  Copyright © 2020 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import UIKit

protocol ViewControllerBuilder {
    func createViewController<VC: UIViewController>(of type: VC.Type) -> VC
}

extension ViewControllerBuilder where Self: RawRepresentable, Self.RawValue == String {
    func createViewController<VC: UIViewController>(of type: VC.Type) -> VC {
        let storyboard = UIStoryboard(name: self.rawValue, bundle: nil)
        return storyboard.instantiateViewController(identifier: String(describing: type)) as! VC
    }
}
