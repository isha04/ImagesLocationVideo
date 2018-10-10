//
//  youTubeCell.swift
//  ImagesVideosLocation
//
//  Created by isha on 10/8/18.
//  Copyright © 2018 Isha. All rights reserved.
//

import UIKit

class youTubeCell: UITableViewCell {
    
    @IBOutlet weak var thumbNailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var channelLabel: UILabel!
    var videoID: String!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var video: Video? {
        didSet {
            guard let video = video else { return }
            titleLabel.text = video.videoTitle
            channelLabel.text = video.videoChannel
            videoID = video.videoID
            let url = URL(string: video.videoThumbNailURL)
            if let data = try? Data(contentsOf: url!) {
                thumbNailImage.image = UIImage(data: data)!
            }
        }
    }

}
