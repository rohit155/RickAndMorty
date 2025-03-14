//
//  UIViewController+Ext.swift
//  RickAndMorty
//
//  Created by Rohit on 14/03/25.
//

import UIKit

extension UIViewController {
    // MARK: - Custom toast
    func showToast(message: String, position: ToastPosition = .center, bgColor: UIColor = UIColor(resource: .accent)) {
        
        // Label
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.textColor = UIColor.label
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Toast container
        let padding: CGFloat = 12
        let toastContainer = UIView()
        toastContainer.backgroundColor = bgColor.withAlphaComponent(0.8)
        toastContainer.layer.cornerRadius = 10
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.clipsToBounds = true
        toastContainer.addSubview(toastLabel)
        self.view.addSubview(toastContainer)
        
        // Constraint for container and label
        NSLayoutConstraint.activate([
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: padding),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -padding),
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: padding),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -padding),
        ])
        NSLayoutConstraint.activate([
            toastContainer.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20),
            toastContainer.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -20),
            toastContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        // Position top or bottom
        switch position {
        case .top:
            toastContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        case .bottom:
            toastContainer.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        case .center:
            fallthrough
        default:
            toastContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        }
        
        // Animation to hide toast
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            toastContainer.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 2.0, options: .curveEaseIn, animations: {
                toastContainer.alpha = 0.0
            }) { _ in
                toastContainer.removeFromSuperview()
            }
        }
    }
}
