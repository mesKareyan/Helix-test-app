//
//  NewsTableViewCell.swift
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/26/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var unreadCircleView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unreadCircleView.layer.cornerRadius = unreadCircleView.frame.width / 2.0;
    }
    
    func configure(for newsEntity: NewsItemEntity) {
        if let url = newsEntity.coverPhotoUrl {
            NetworkManager.shared.downloadImage(at: url) { image in
                self.thumbnailImageView.image = image
            }
        }
        if let date = newsEntity.date {
            dateLabel.text = date.shortString
        }
        titleLabel.text = newsEntity.title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
