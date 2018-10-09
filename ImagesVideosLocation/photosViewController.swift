//
//  photosViewController.swift
//  ImagesVideosLocation
//
//  Created by isha on 10/7/18.
//  Copyright © 2018 Isha. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class photosViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var photosCollection: UICollectionView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    var allPictures = [UIImage]()
    let imagePicker = UIImagePickerController()
    var newPicture: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        //shareButton.isEnabled = true
        if cameraAuthorizationStatus == .authorized {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            alertWithTitle(title: "Access Denied", message: "Change permission settings to make use of the app")
        }
    }
    
    @IBAction func pickImagefromAlbum(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newPicture = image
            allPictures.append(image)
            if imagePicker.sourceType == .camera {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        if allPictures.count > 0 {
            addLabel.isHidden = true
        }
        saveImageInCoreData()
        photosCollection.reloadData()
        dismiss(animated: true, completion: nil)
    }
 
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            alertWithTitle(title: "Could not save to phone gallery.Check permission settings.", message: error.localizedDescription)
        } else {
            alertWithTitle(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}


extension photosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! imageViewCell
        cell.imageCell.image = allPictures[indexPath.row]
        return cell
    }
}


extension photosViewController {
    func fetchData() {
        // Set up fetch request
        let container = appDelegate.persistentContainer
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<Image>(entityName: "Image")
        
        do {
            // Retrive array of all image entities in core data
            let images = try context.fetch(fetchRequest)
            
            // For each image entity get the imageData from filepath and assign it to image view
            for image in images {
                if let filePath = image.filePath {
                    if FileManager.default.fileExists(atPath: filePath) {
                        if let contentsOfFilePath = UIImage(contentsOfFile: filePath) {
                            allPictures.append(contentsOfFilePath)
                        }
                    }
                }
            }
            if allPictures.count > 0 {
                addLabel.isHidden = true
            } else if allPictures.count == 0 {
                addLabel.isHidden = false
            }
            photosCollection.reloadData()
        } catch {
            alertWithTitle(title: "Pictures could not be fetched", message: "Try Again")
        }
    }
    
    
    func saveImageInCoreData() {
        let fileManager = FileManager.default
        let documentsURL =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let timeStamp = NSDate().timeIntervalSince1970
        let filePath = documentsURL.appendingPathComponent("\(String(timeStamp)).png")

        // Create imageData and write to filePath
        do {
            if let jpegImageData = UIImageJPEGRepresentation(newPicture!, 1.0) {
                try jpegImageData.write(to: filePath, options: .atomic)
            }
        } catch {
            print("couldn't write image")
        }
        
        // Save filePath and imagePlacement to CoreData
        let container = appDelegate.persistentContainer
        let context = container.viewContext
        let entity = Image(context: context)
        entity.filePath = filePath.path
        appDelegate.saveContext()
    }
}
