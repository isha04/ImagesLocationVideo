//
//  File.swift
//  ImagesVideosLocation
//
//  Created by isha on 10/8/18.
//  Copyright © 2018 Isha. All rights reserved.
//

struct Video {
    var videoID: String
    var videoTitle: String
    var videoThumbNailURL: String
    var videoChannel: String
    
    init(videoID: String, videoTitle: String, videoThumbNailURL: String, videoChannel: String) {
        self.videoID = videoID
        self.videoTitle = videoTitle
        self.videoThumbNailURL = videoThumbNailURL
        self.videoChannel = videoChannel
    }
    

}
