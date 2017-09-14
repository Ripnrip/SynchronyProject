//
//  ViewController.swift
//  SynchronyFinancialProject
//
//  Created by Admin on 9/6/17.
//  Copyright © 2017 Binary Bros. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet var webView: UIWebView!
    

    
    override func viewWillAppear(_ animated: Bool) {
        webView.loadRequest(URLRequest(url: URL(string: "https://api.imgur.com/oauth2/authorize?client_id=66f1846bf28f524&response_type=code&state=APPLICATION_STATE")!))
        webView.delegate = self

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func refreshPage(_ sender: Any) {
        webView.loadRequest(URLRequest(url: URL(string: "https://api.imgur.com/oauth2/authorize?client_id=66f1846bf28f524&response_type=code&state=APPLICATION_STATE")!))
    }

    func webView(_ webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        //Stop Webview from going to unrelated pages
        if request.url?.absoluteString == "https://m.imgur.com/assets/appcache/manifest.html" || request.url?.absoluteString == "https://imgur.com/register" {
            return false
        }
        
        var dict = [String:String]()
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        
        guard let queryItems = components.queryItems else {return true}
        for item in queryItems {
            guard let value = item.value else {return true}
            dict[item.name] = value
            
            if item.name == "code" {
                print("got the code to exchange for token! \(item.value!)")
                //invoke exchange here
                Networking.sharedInstance.authorizeUserWithCode(code: item.value!, completionHandler: {success in
                    if success == true{
                        //proceed to the next vc
                        print("successfully authorized user, going to home page")
                        self.performSegue(withIdentifier: "goHome", sender: nil)
                    }else{
                        //alert user to try pin again, or refresh the page
                        print("error in authorizing, should probably refresh webview and try again")
                    }
                })
            }
        }
        print("the query items are \(queryItems)")
        return true
    }



}

