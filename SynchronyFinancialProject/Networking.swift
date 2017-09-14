//
//  Networking.swift
//  SynchronyFinancialProject
//
//  Created by Admin on 9/6/17.
//  Copyright © 2017 Binary Bros. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSpinner

class Networking {
    
    static let sharedInstance = Networking()

    private let clientID = "66f1846bf28f524"
    private let clientSecret = "9c5faea69250f19ce628a0cafeb3b7d276af3580"
    
    private static let authorizationURL = ""
    
    var token_type:String?
    var refresh_token:String?
    var access_token:String?
    var account_id:Int?
    var account_username:String?
    
    var usersPhotos:[ImgurPhoto] = []
    
    
    //MARK: Authorize user
    func authorizeUserWithCode (code:String, completionHandler:@escaping (Bool) -> () ) {
        let url = URL(string: "https://api.imgur.com/oauth2/token")!
        
        let params: [String: String] = ["grant_type": "authorization_code", "client_id": "\(clientID)", "client_secret": "\(clientSecret)","code":"\(code)"]

        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200..<600).responseJSON() { response in
            
            switch response.result {
            case .success:

                if let value = response.result.value {
                    print("the response is \(value)")
                    
                    guard let dict = value as? [String:Any] else {
                        print("error changing value to dict")
                        return
                    }
                    if (dict["status"]) as? Int == 400 {
                        print("wrong pin error, try again")
                        completionHandler(false)
                        return
                    }
                    print("the dict value is \(dict))")

                    self.token_type = (dict["token_type"] as? String)
                    self.refresh_token = (dict["refresh_token"] as? String)
                    self.access_token = (dict["access_token"] as? String)
                    self.account_id = (dict["account_id"] as? Int)
                    self.account_username = (dict["account_username"] as? String)
                    completionHandler(true)
                }
                
            case .failure(let error):
                print("RESPONSE ERROR: \(error)")
                completionHandler(false)
                
            }
        }
    }
    
    //MARK: Get photos for user
    func getPhotosForUser(completionHandler: @escaping (Bool) -> () ) {
        usersPhotos = []
        guard let username = account_username else {return}
        guard let token = access_token else {return}
        
        guard let url = URL(string: "https://api.imgur.com/3/account/\(username)/images/0") else {return}
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).validate(statusCode: 200..<600).responseJSON() { response in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    print("the response for get photos is \(value)")
                    
                    guard let dict = value as? [String:Any] else {
                        print("error changing value to dict")
                        return
                    }
                    if (dict["success"]) as? Bool == false {
                        print("error in getting photos, try again")
                        completionHandler(false)
                        return
                    }
                    print("the dict value for the get photos is is \(dict))")
                    //set pictures array
                    guard let photoArray = dict["data"] as? NSArray else {return}
                    photoArray.forEach({ (item) in
                        let dictObject = item as! [String:Any]
                        guard let imageURL = dictObject["link"] as? String else {return}
                        guard let deleteHashString = dictObject["deletehash"] as? String else {return}
                        
                        let photo = ImgurPhoto(link: imageURL, deleteHash: deleteHashString)
                        self.usersPhotos.append(photo)
                    })

                    
                    completionHandler(true)
                }
                
            case .failure(let error):
                print("RESPONSE ERROR: \(error)")
                completionHandler(false)
            }
        }
    }
    
    //MARK: Upload photo
    func uploadPhoto(image:UIImage, completionHandler: @escaping (Bool) -> () ) {
        guard let url = URL(string: "https://api.imgur.com/3/image") else {return}
        
        guard let token = access_token else {return}
        
        let data:Data = UIImagePNGRepresentation(image)!
        let strBase64 = data.base64EncodedString(options: .lineLength64Characters)

        let headers: HTTPHeaders = [
            "Authorization": "Client-ID \(clientID)",
            "content-type": "multipart/form-data",
            "image": "\(data)"
        ]
      
        Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "file")
            
            for (key, value) in headers {
                multipartFormData.append((value.data(using: .utf8))!, withName: key)
            }}, to: "\(url)", method: .post, headers: [
                "Authorization": "Client-ID \(clientID)",
                "content-type": "multipart/form-data",
                "image": "\(data)"
            ],
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        DispatchQueue.main.async {
                            SwiftSpinner.show("Uploading...")
                        }
                        upload.uploadProgress(closure: { (progress) in
                            print("Upload Progress: \(progress.fractionCompleted*100)%")
                        })
                        
                        upload.responseJSON() { (response) in
                            print(response)
                            guard let value = response.result.value else {return}
                            guard let dict = value as? [String:Any] else {
                                print("error changing value to dict")
                                SwiftSpinner.hide()
                                return
                            }
                            if (dict["status"]) as? Int == 400 {
                                print("error saving the image \(dict)")
                                SwiftSpinner.hide()
                                completionHandler(false)
                                return
                            }
                            print("the dict value for the get photos is is \(dict))")
                            SwiftSpinner.hide()
                            completionHandler(true)
                        }

                    case .failure(let encodingError):
                        print("error:\(encodingError)")
                        completionHandler(false)
                    }
        })
    }
    
    //MARK: Delete photo
    func deletePhoto(imageHash:String, completionHandler: @escaping (Bool) -> () ) {
        guard let url = URL(string: "https://api.imgur.com/3/image/\(imageHash)") else {return}
        
        guard let token = access_token else {return}
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "content-type": "multipart/form-data"
        ]
        Alamofire.request(url, method: .delete, parameters: headers, encoding: URLEncoding.default, headers: headers).validate(statusCode: 200..<600).responseJSON() { response in
            
            switch response.result {
                case .success:
                    guard let value = response.result.value else {return}
                    print(response)
                    completionHandler(true)

                
                case .failure(let encodingError):
                    print("error:\(encodingError)")
                    completionHandler(false)
            }
        }
    }
    
    
}
