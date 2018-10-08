//
//  youTubeCell.swift
//  ImagesVideosLocation
//
//  Created by Amarjeet on 10/8/18.
//  Copyright © 2018 Isha. All rights reserved.
//

import UIKit

class youTubeCell: UITableViewCell {
    
    @IBOutlet weak var thumbNailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var channelLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var video: Video? {
        didSet {
            guard let video = video else { return }
            titleLabel.text = video.videoTitle
            channelLabel.text = video.videoChannel
            
            let url = URL(string: video.videoThumbNailURL)
            if let data = try? Data(contentsOf: url!) {
                thumbNailImage.image = UIImage(data: data)!
            }
        }
    }

}
