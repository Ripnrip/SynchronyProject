//
//  HomeViewController.swift
//  SynchronyFinancialProject
//
//  Created by Admin on 9/6/17.
//  Copyright © 2017 Binary Bros. All rights reserved.
//

import UIKit
import SwiftSpinner

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var picturesCollectionView: UICollectionView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        picturesCollectionView.delegate = self
        guard let username = Networking.sharedInstance.account_username else {return}
        welcomeLabel.text = "Welcome \(username) !"
        
        Networking.sharedInstance.getPhotosForUser { (success) in
            if success == true {
                print("got the user's photos \(Networking.sharedInstance.usersPhotos)")
                self.picturesCollectionView.reloadData()
                if Networking.sharedInstance.usersPhotos.count == 0 {
                    //show empty collectionview, and prompt user to upload photo
                    print("user has no photos, ask them to upload")
                    self.askUserToUploadPhoto()
                }
                
            }else{
                print("error geting the user's photos")
            }
        }
    }
    
     func askUserToUploadPhoto() {
        let alert = UIAlertController(title: "No Photos", message: "Would you like to upload your first photo?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { _ in
            self.uploadImage()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { _ in
            //handle no
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func uploadButtonPressed(_ sender: Any) {
        uploadImage()
    }
    func uploadImage(){
        //upload photo from photo library
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(self.imagePicker, animated: true, completion: nil)
    }
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {


         if let orginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            Networking.sharedInstance.uploadPhoto(image: orginalImage, completionHandler: { (success) in
                if success{
                    print("uploaded the photo")
                }else{
                    print("error saving the uploaded photo")
                }
            })
        }
        else { print ("error") }
        
        /// if the request successfully done just dismiss
        picker.dismiss(animated: true, completion: nil)
        
    }
}

