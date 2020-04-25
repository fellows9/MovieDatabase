//
//  ShowTableViewCell.swift
//  MovieDatabase
//
//  Created by Steven Fellows on 4/24/20.
//  Copyright © 2020 Steven Fellows. All rights reserved.
//

import UIKit

class ShowTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with show: Show) {
        titleLabel.text = show.title
        
        if let url = show.posterURL {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url)
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async { [weak self] in
                        self?.posterImageView?.image = image
                    }
                }
            }
        }
    }

    
}
