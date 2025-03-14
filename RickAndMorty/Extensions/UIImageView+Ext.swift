//
//  UIImageView+Ext.swift
//  RickAndMartin
//
//  Created by Rohit on 18/01/25.
//

import UIKit

extension UIImageView {
    func downloadImage(fromURL url: String) {
        APIManager().downloadImage(from: url) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async{ self.image = image }
        }
    }
}
