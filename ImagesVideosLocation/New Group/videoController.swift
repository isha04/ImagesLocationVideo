//
//  videoController.swift
//  ImagesVideosLocation
//
//  Created by isha on 10/8/18.
//  Copyright © 2018 Isha. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import youtube_ios_player_helper

// Just a tip: Always start class names with capital letters. Small letter class names is wrong according to convention. Just saying. :P
class videoController: UIViewController, UITableViewDelegate, UITableViewDataSource, YTPlayerViewDelegate {
    
    let apiKey = "AIzaSyBwOuUidqOttySc54DkwukcE7eLjCh8icQ"
    private let searchText = "swift,programming,language"
    
    // Use let instead of var in Video model. We don't have to change those properties ever. So make them immutable. Init is also not needed in struct as struct automatically provides default init.
    private var videos = [Video]()
    
    private let youtubeView = YTPlayerView()
    private let closeVideoButton = UIButton()
    
    @IBOutlet weak var videoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.youtubeView.delegate = self
        
        setUpVideo()
        
        fetchVideo()
        addSwipeDownGestureRecognizer()
    }
    
    private func fetchVideo() {
        Alamofire.request("https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,channelTitle,thumbnails))&order=viewCount&q=\(searchText)&type=video&maxResults=25&key=\(apiKey)").responseJSON(completionHandler: { response in
            guard let validResponse = response.result.value else { return }
            
            var videos = [Video]()
            let swiftyJsonVar = JSON(validResponse)
            if let resData = swiftyJsonVar["items"].arrayObject  {
                let x = resData as! [[String: AnyObject]]
                for i in x {
                    let thumbs = i["snippet"]?["thumbnails"] as! [String: AnyObject]
                    let aVideo = Video(videoID: i["id"]?["videoId"] as! String,
                                       videoTitle: i["snippet"]?["title"] as! String,
                                       videoThumbNailURL: thumbs["default"]!["url"] as! String,
                                       videoChannel: i["snippet"]?["channelTitle"] as! String)
                    videos.append(aVideo)
                }
                self.videos = videos
                self.videoTable.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = videoTable.dequeueReusableCell(withIdentifier: "youTubeCell", for: indexPath) as! youTubeCell
        cell.video = videos[indexPath.row]
        //videoView.isHidden = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedVideo = videos[indexPath.row]
        
        youtubeView.alpha = 1.0
        
        youtubeView.load(withVideoId: selectedVideo.videoID, playerVars: ["controls": 1, "playsinline": 1, "autohide": 1, "showinfo": 1, "autoplay": 1, "modestbranding": 1])
        
        //https://github.com/youtube/youtube-ios-player-helper/issues/292
        
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        youtubeView.playVideo()
    }
    
    @objc private func closeVideo(sender: UIButton!) {
        youtubeView.stopVideo()
        
        // No need to remove YouTubeView everytime and then laying out again. Instead we can just hide it. This will reduce memory footprint of app.
        UIView.animate(withDuration: 0.5) {
            self.youtubeView.alpha = 0.0
        }
    }
    
    // YouTube player won't cover the whole screen because of safe area layout guide. I tried to override safe area layout guide in our app but it seems like the library which you're using doesn't let you add YouTubeView beyond safe area layout guides.
    private func setUpVideo() {
        youtubeView.alpha = 0.0
        
        // Adding YoutubeView to app window so it also covers navigation bar and tab bar.
        guard let window = UIApplication.shared.keyWindow else { return }
        
        window.addSubview(youtubeView)
        
        youtubeView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = youtubeView.topAnchor.constraint(equalTo: window.topAnchor, constant: 0)
        let leadingConstraint = youtubeView.leadingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leadingAnchor, constant: 0)
        let trailingConstraint = youtubeView.trailingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.trailingAnchor, constant: 0)
        let bottomConstraint = youtubeView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([topConstraint,
                                     leadingConstraint,
                                     trailingConstraint,
                                     bottomConstraint])
    }
    
    private func addSwipeDownGestureRecognizer() {
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeVideo))
        swipeDownGesture.direction = .down
        
        youtubeView.addGestureRecognizer(swipeDownGesture)
    }
    
    private func setUpButton() {
        closeVideoButton.frame = CGRect(x: 0 , y: 0, width: 30, height: 32)
        youtubeView.addSubview(closeVideoButton)
        closeVideoButton.setTitle("x", for: .normal)
        closeVideoButton.setTitleColor(UIColor.gray, for: .normal)
        closeVideoButton.backgroundColor = .red
       // closeVideoButton.translatesAutoresizingMaskIntoConstraints = false
        closeVideoButton.addTarget(self, action: #selector(self.closeVideo), for: .touchUpInside)
//        let leadingConstraint = NSLayoutConstraint(item: closeVideoButton, attribute: .leading, relatedBy: .equal, toItem: youtubeView, attribute: .leading, multiplier: 1, constant: 0)
//        let topConstraint = NSLayoutConstraint(item: closeVideoButton, attribute: .top, relatedBy: .equal, toItem: youtubeView, attribute: .trailing, multiplier: 1, constant: 0)
//       closeVideoButton.addConstraints([leadingConstraint, topConstraint])
    }
}
