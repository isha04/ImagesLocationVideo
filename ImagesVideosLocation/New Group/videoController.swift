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

class videoController: UIViewController, UITableViewDelegate, UITableViewDataSource, YTPlayerViewDelegate {

    let apiKey = "AIzaSyBwOuUidqOttySc54DkwukcE7eLjCh8icQ"
    var searchText = "swift,programming,language"
    var videos = [Video]()
    let youtubeView = YTPlayerView()
    let closeVideoButton = UIButton()
    @IBOutlet weak var videoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.youtubeView.delegate = self
        fetchVideo()
    }
    
    func fetchVideo() {
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
        let selectedVideo = videos[indexPath.row]
        setUpVideo()
        //setUpButton()
        youtubeView.load(withVideoId: selectedVideo.videoID, playerVars: ["controls": 1, "playsinline": 1, "autohide": 1, "showinfo": 1, "autoplay": 1, "modestbranding": 1])
        
        //https://github.com/youtube/youtube-ios-player-helper/issues/292
        
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        youtubeView.playVideo()
    }
    
    
    @objc func closeVideo(sender: UIButton!) {
       youtubeView.stopVideo()
        UIView.animate(withDuration: 1, animations: ({
            self.youtubeView.alpha = 0.0
        }), completion: { _ in
            self.youtubeView.removeFromSuperview()
        })
       
    }
    
    func setUpVideo() {
        youtubeView.frame  = CGRect(x: 0 , y: 423, width: self.view.frame.width, height: 180)
        self.view.addSubview(youtubeView)
        var swipeDown: UISwipeGestureRecognizer?
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(closeVideo))
        swipeDown?.direction = .down
        youtubeView.addGestureRecognizer(swipeDown!)
        
        //youtubeView.translatesAutoresizingMaskIntoConstraints = false
//        let leadingConstraint = NSLayoutConstraint(item: youtubeView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
//        let trailingConstraint = NSLayoutConstraint(item: youtubeView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
//        let bottomConstraint = NSLayoutConstraint(item: youtubeView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
//        view.addConstraints([leadingConstraint, trailingConstraint, bottomConstraint])
        //youtubeView.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 154))
        
        
    }
    
    
    func setUpButton() {
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





