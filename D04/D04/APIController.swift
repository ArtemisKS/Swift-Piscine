import Foundation
import UIKit

class APIController {
    weak var delegate : APITwitterDelegate?
    let token : String
    init(delegate: APITwitterDelegate, token: String) {
        self.delegate = delegate
        self.token = token
    }
    
    private func appendTweets(arrayOfStatuses: [[String : AnyObject]], tweets: inout [Tweet]) {
        for status in arrayOfStatuses {
//			print("tweetJSON #\(index): \(status)")
			var text = ""
			if let retStatus = status["retweeted_status"] {
				text = retStatus["full_text"] as! String
			} else {
            	text = status["full_text"] as! String
			}
            let user = status["user"]?["name"]  as! String
            if let date = status["created_at"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
                if let date = dateFormatter.date(from: date) {
                    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                    let newDate = dateFormatter.string(from: date)
                    tweets.append(Tweet(name: user, text: text, date: newDate))
                }
            }
        }
    }
    
	func getFromTwitter(str : String, nbr : Int, vc: UIViewController, lang: String) {
        var tweets = [Tweet]()
        
        let q = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let myURLRequest = NSMutableURLRequest(url: URL(string : "https://api.twitter.com/1.1/search/tweets.json?q=\(q)&count=\(nbr)&lang=\(lang)&result_type=recent&tweet_mode=extended")!)
        myURLRequest.httpMethod = "GET"
        myURLRequest.setValue("Bearer " +  self.token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: myURLRequest as URLRequest, completionHandler: {
            (data, response, error) in
            if let err = error {
                if let myDelegate: APITwitterDelegate = self.delegate {
                    myDelegate.processError(err as NSError)
                }
            } else if let d = data {
                do {
                    if let responseObject = try JSONSerialization.jsonObject(with: d, options: []) as? [String:AnyObject],
                        let arrayStatuses = responseObject["statuses"] as? [[String:AnyObject]] {
                        guard arrayStatuses.count > 0 else {
                            Utils.alert(title: "Oops!", message: "Unfortunately, your query \"\(str)\" was not found", prefStyle: .alert, handler: nil, vc: vc)
                            return
                        }
                        self.appendTweets(arrayOfStatuses: arrayStatuses, tweets: &tweets)
                    }
                    if let myDelegate = self.delegate {
                        myDelegate.processTweet(tweets)
                    }
                } catch _{
                    Utils.alert(title: "Oops!", message: "Connection lost", prefStyle: .alert, handler: nil, vc: vc)
                }
            }
        })
        task.resume()
    }
}
