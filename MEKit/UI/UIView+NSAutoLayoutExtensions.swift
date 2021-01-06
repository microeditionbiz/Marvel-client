//
//  UIView+NSAutoLayoutExtensions.swift
//  SwiftRSSReader
//
//  Created by Pablo Ezequiel Romero Giovannoni on 16/07/2020.
//  Copytrailing © 2020 Pablo Ezequiel Romero Giovannoni. All trailings reserved.
//

import UIKit

struct AutoLayoutEdge: OptionSet {
    let rawValue: Int
    
    static let top = AutoLayoutEdge(rawValue: 1 << 0)
    static let bottom = AutoLayoutEdge(rawValue: 1 << 1)
    static let leading = AutoLayoutEdge(rawValue: 1 << 2)
    static let trailing = AutoLayoutEdge(rawValue: 1 << 2)
    
    static let all: AutoLayoutEdge = [.top, .bottom, .leading, .trailing]
}

extension UIView {
    
    func edgesToSuperview(includingEdges: AutoLayoutEdge = .all, edgeInsets: UIEdgeInsets = .zero) {
        guard let superview = superview else {
            fatalError("The view has to have a parent view")
        }
        
        var constraints = [NSLayoutConstraint]()
        
        if includingEdges.contains(.top) {
            constraints.append(self.topAnchor.constraint(equalTo: superview.topAnchor, constant: edgeInsets.top))
        }
        
        if includingEdges.contains(.bottom) {
            constraints.append(self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: edgeInsets.bottom))
        }
        
        if includingEdges.contains(.leading) {
            constraints.append(self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: edgeInsets.left))
        }
        
        if includingEdges.contains(.trailing) {
            constraints.append(self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: edgeInsets.right))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func edgesToSuperviewMarings(includingEdges: AutoLayoutEdge = .all, edgeInsets: UIEdgeInsets = .zero) {
        guard let superview = superview else {
            fatalError("The view has to have a parent view")
        }
        
        var constraints = [NSLayoutConstraint]()
        
        if includingEdges.contains(.top) {
            constraints.append(self.topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor, constant: edgeInsets.top))
        }
        
        if includingEdges.contains(.bottom) {
            constraints.append(self.bottomAnchor.constraint(equalTo: superview.layoutMarginsGuide.bottomAnchor, constant: edgeInsets.bottom))
        }
        
        if includingEdges.contains(.leading) {
            constraints.append(self.leadingAnchor.constraint(equalTo: superview.layoutMarginsGuide.leadingAnchor, constant: edgeInsets.left))
        }
        
        if includingEdges.contains(.trailing) {
            constraints.append(self.trailingAnchor.constraint(equalTo: superview.layoutMarginsGuide.trailingAnchor, constant: edgeInsets.right))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func edgesToSuperviewSafeArea(includingEdges: AutoLayoutEdge = .all, edgeInsets: UIEdgeInsets = .zero) {
        guard let superview = superview else {
            fatalError("The view has to have a parent view")
        }
        
        var constraints = [NSLayoutConstraint]()
        
        if includingEdges.contains(.top) {
            constraints.append(self.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: edgeInsets.top))
        }
        
        if includingEdges.contains(.bottom) {
            constraints.append(self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: edgeInsets.bottom))
        }
        
        if includingEdges.contains(.leading) {
            constraints.append(self.leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left))
        }
        
        if includingEdges.contains(.trailing) {
            constraints.append(self.trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: edgeInsets.right))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
