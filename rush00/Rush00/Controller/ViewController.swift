//
//  ViewController.swift
//  Rush00
//
//  Created by Artem KUPRIIANETS on 4/6/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.



import UIKit
import WebKit

var UID = "bc200d535a264c1956f6a437b865b7ebe25213495e202599da0e8eeff1fd85fd"
var SKEY = "d5db87916aa0adb551a3005cf521fc5fdb31226f11bdb5d444359cdccbf5f88c"

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    var token: String?

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let state = Utils.randomStr(length: 64)
        let queryItems = [
            NSURLQueryItem(name: "client_id", value: UID),
            NSURLQueryItem(name: "redirect_uri", value: "https://127.0.0.1"),
            NSURLQueryItem(name: "scope", value: "public forum"),
            NSURLQueryItem(name: "state", value: state),
            NSURLQueryItem(name: "response_type", value: "code"),
        ]
        let urlComps = NSURLComponents(string: "https://api.intra.42.fr/oauth/authorize")!
        urlComps.queryItems = queryItems as [URLQueryItem]
        let url = urlComps.url!
        let accessRequest = NSMutableURLRequest(url: url)
//        accessRequest.httpMethod = "POST"
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.load(accessRequest as URLRequest)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login_segue" {
            if let destinationVC = segue.destination as? ThemesViewController {
                let token = sender as? String
                destinationVC.apiController = APIController(token: token!)
            }
        }
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation: WKNavigation!) {
        guard let url = URLComponents(string: (webView.url?.absoluteString)!) else { return }
        guard let code = url.queryItems?.first(where: { $0.name == "code" })?.value else { return }
        guard let state = url.queryItems?.first(where: { $0.name == "state" })?.value else { return }
        self.authApp(code: code, state: state) { dictionary in
            let token = dictionary.value(forKey: "access_token")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "login_segue", sender: token)
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(WKNavigationResponsePolicy.allow)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func authApp(code: String, state: String, completionHandler: @escaping (NSDictionary) -> Void) {
        let queryItems = [
            NSURLQueryItem(name: "grant_type", value: "authorization_code"),
            NSURLQueryItem(name: "client_id", value: UID),
            NSURLQueryItem(name: "client_secret", value: SKEY),
            NSURLQueryItem(name: "code", value: code),
            NSURLQueryItem(name: "redirect_uri", value: "https://127.0.0.1"),
            NSURLQueryItem(name: "state", value: state),
        ]
        let urlComps = NSURLComponents(string: "https://api.intra.42.fr/oauth/token")!
        urlComps.queryItems = queryItems as [URLQueryItem]
        let url = urlComps.url!
        
        let accessRequest = NSMutableURLRequest(url: url)
        accessRequest.httpMethod = "POST"

        let session = URLSession.shared
        session.dataTask(with: accessRequest as URLRequest) { (data, urlResponse, error) in
            if let error = error {
				Utils.alert(title: "Oops", message: error.localizedDescription, prefStyle: .alert, vc: self)
                return
            }
            guard let data = data else { return }
            do {
                if let dic: NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    completionHandler(dic)
                }
            }
            catch (let error) {
				Utils.alert(title: "Oops", message: error.localizedDescription, prefStyle: .alert, vc: self)
            }
        }.resume()
    }
}

