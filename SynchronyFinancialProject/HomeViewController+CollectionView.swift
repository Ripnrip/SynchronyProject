//
//  HomeViewController+CollectionView.swift
//  SynchronyFinancialProject
//
//  Created by Admin on 9/13/17.
//  Copyright © 2017 Binary Bros. All rights reserved.
//
import Foundation
import UIKit
import AlamofireImage
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Networking.sharedInstance.usersPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentImage = Networking.sharedInstance.usersPhotos[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! PictureCollectionViewCell
    
        guard let url = URL(string:currentImage.link!) else {return UICollectionViewCell()}
        cell.pictureImageView?.af_setImage(withURL: url, placeholderImage: nil)
        cell.deleteButton.addTarget(self, action: #selector(deleteAction(sender:)), for: .touchUpInside)
        cell.deleteButton.tag = indexPath.row
        
        return cell
    }
    

    func deleteAction(sender: UIButton!) {
        print("delete tapped")
        let currentImage = Networking.sharedInstance.usersPhotos[sender.tag]
        guard let hash = currentImage.deleteHash else {return}
        
        let alert = UIAlertController(title: "Delete Photo", message: "Would you like to delete this photo?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { _ in
            self.deletePhoto(hash: hash)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { _ in
            //handle no
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deletePhoto(hash:String){
        Networking.sharedInstance.deletePhoto(imageHash: hash) { (success) in
            if success {
                print("deleted the photo")
                Networking.sharedInstance.getPhotosForUser(completionHandler: { (success) in
                    if success{
                        self.picturesCollectionView.reloadData()
                    }
                })
            }else{
                print("failed deleting the photo")
            }
        }
    }
    
}
