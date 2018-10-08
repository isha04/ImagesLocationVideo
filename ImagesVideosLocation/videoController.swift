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

class videoController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let apiKey = "AIzaSyBwOuUidqOttySc54DkwukcE7eLjCh8icQ"
    var searchText = "dogs"
    var videos = [Video]()
    
    @IBOutlet weak var videoTable: UITableView!
    @IBOutlet weak var seachBar: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return cell
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = seachBar.text!
        print(searchText)
        fetchVideo()
        return true
    }
    
}





