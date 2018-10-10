//
//  helpers.swift
//  ImagesVideosLocation
//
//  Created by isha on 10/7/18.
//  Copyright © 2018 Isha. All rights reserved.
//

import UIKit

extension UIViewController {
    func alertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
