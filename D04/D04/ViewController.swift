import UIKit

class ViewController: UIViewController, APITwitterDelegate, UITableViewDataSource, UITableViewDelegate{
    
//    fileprivate let API_KEY = "P0fvFRi2jNl7OoRhIsDK3waUq"
//    fileprivate let API_SECRET = "a85vwrySlBIsyCuto33AtwPVxa1asvzw4ocIjVwAQtfEFoDazd"
    let consumerKey : String = "iA8rFDKtJnbjCRwIRN9rkjmDA"
    let consumerSecret : String = "wF8C9YDzbVNZb8RJbPVGjCYWD6jBDQJ9soNEY2933cLktv8PcI"
    var token : String = ""
    var apiController : APIController?
    var tweets : [Tweet] = []
    var tweetSearchText = "Ecole42"
    let tweetsNum = 100
    var lang = "fr"
	var dict = [String:UIImageView?]()
	let langs = ["fr", "en", "ar", "es", "de", "it", "id", "pt", "ko", "tr",
        "ru", "nl", "fil", "msa", "zh-cn", "hi", "no", "sv", "fi", "da", "pl",
        "hu", "he", "ur", "th"]
	let flagsKeys = ["fr", "en", "es", "de", "it", "ru", "fi", "sv", "pl", "nl", "pt"]
	let flagsImages = [UIImage(named: "France.svg"), UIImage(named: "United_Kingdom.svg"), UIImage(named: "Spain.svg"), UIImage(named: "Germany.svg"), UIImage(named: "Italy.svg"), UIImage(named: "Russia.svg"), UIImage(named: "Finland.svg"), UIImage(named: "Sweden.svg"), UIImage(named: "Poland.svg"), UIImage(named: "Netherlands.svg"), UIImage(named: "Portugal.svg")]
	var flagsIViews = [UIImageView]()
	var curImageBackColor: UIColor = .black
    
    @IBOutlet weak var tweetTextField: UITextField! {
        didSet {
            if let ph = tweetTextField.placeholder {
                print("placeholder, \(ph)!")
            }
        }
    }
	@IBOutlet weak var langPickerView: UIPickerView!
    
    @IBOutlet var tableView: UITableView!
    var tweetLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tweetTextField.delegate = self
        langPickerView.delegate = self
        langPickerView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
		flagsIViews = flagsImages.flatMap({ UIImageView(image: $0) })
		dict = Dictionary(uniqueKeysWithValues: langs.map{ ($0, nil) })
		for (index, flagKey) in flagsKeys.enumerated() {
			dict[flagKey] = flagsIViews[index]
		}
		if let val = dict[lang], let initBackView = val {
			DispatchQueue.main.async {
				self.setBackgroundImageToView(view: self.langPickerView, imageView: initBackView)
			}
		}
        getTweets()
		self.langPickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    func getTweets() {
        let request = getRequest()
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                if let dic: NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    self.token = dic["access_token"] as? String ?? ""
                    self.apiController = APIController(delegate: self, token: self.token)
                    self.apiController?.getFromTwitter(str: self.tweetSearchText, nbr: self.tweetsNum, vc: self, lang: self.lang)
                }
            }
            catch (let err) {
                Utils.alert(title: nil, message: err.localizedDescription, prefStyle: .alert, handler: nil, vc: self)
            }
        }
        task.resume()
    }
    
    //MARK: APITwitterDelegate methods
    
    func processTweet(_ tweets : [Tweet]) {
        self.tweets = tweets
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func processError(_ error : NSError) {
        Utils.alert(title: nil, message: error.localizedDescription, prefStyle: .alert, handler: nil, vc: self)
    }
	
	//MARK: TableView delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellRet : UITableViewCell?
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCellId", for: indexPath) as? TweetTableViewCell  {
            cell.title.text = self.tweets[indexPath.row].name
            cell.dateTweet.text = self.tweets[indexPath.row].date
            cell.content?.text = self.tweets[indexPath.row].text
			cell.content.sizeToFit()
			if tweetSearchText.trimmingCharacters(in: CharacterSet(charactersIn: " \t")).capitalized == "Ecole42" {
                let iv = UIImageView(image: UIImage(named: "background42"))
                iv.contentMode = .redraw
                cell.backgroundView = iv
                setColorsForLabels(color: .white, labels: cell.dateTweet, cell.content, cell.title)
            } else {
                cell.backgroundColor = UIColor(red: 29/255, green: 202/255, blue: 1.0, alpha: 1.0)
                cell.backgroundView = nil
                setColorsForLabels(color: .black, labels: cell.dateTweet, cell.content, cell.title)
            }
            cellRet = cell
        }
        return cellRet!
    }
    
    //MARK: encapsulated private functionality
    
    private func setColorsForLabels(color: UIColor, labels: UILabel...) {
        labels.forEach { $0.textColor = color }
    }
    
    private func getRequest() -> URLRequest {
        let credents = ((consumerKey + ":" + consumerSecret).data(using: String.Encoding.utf8))?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let url = URL(string: "https://api.twitter.com/oauth2/token")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("Basic " + credents!, forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: String.Encoding.utf8)
        return request
    }
}

extension ViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return langs.count
    }
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let data = langs[row]
		let attrData = NSAttributedString(string: data, attributes: [NSAttributedStringKey.foregroundColor: curImageBackColor.isLight() ? UIColor.black : UIColor.white])
		return attrData
	}
	
	private func viewHasIVasSV(view: UIView) -> Bool {
		var hasIV = false
		for sv in view.subviews where sv is UIImageView {
			hasIV = true
		}
		return hasIV
	}
	
//	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//		var myView = UIView(frame: pickerView.bounds)
//		lang = langs[row]
//		if let val = dict[lang], let flagIV = val, !viewHasIVasSV(view: pickerView) {
//			flagIV.center = myView.center
//			flagIV.frame = myView.bounds
//			flagIV.contentMode = .center
//			myView.addSubview(flagIV)
//		} else {
//			for sv in pickerView.subviews where sv is UIImageView {
//				sv.isHidden = true
//			}
//			pickerView.backgroundColor = UIColor(red: 0, green: 172/255, blue: 237/255, alpha: 1.0)
//		}
//		return myView
//	}
	
	private func setBackgroundImageToView(view: UIView, imageView: UIImageView) {
		guard let image = imageView.image else { return }
		imageView.frame = CGRect(x: view.bounds.width * 0.1, y: view.bounds.height * 0.1, width: view.bounds.width * 0.8, height: view.bounds.height * 0.8)
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFill
		imageView.layer.borderWidth = 4
		view.addSubview(imageView)
//		imageView.center = view.center
//		imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//		imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//		imageView.layer.borderColor = UIColor.black.cgColor
		view.sendSubview(toBack: imageView)
		curImageBackColor = image.averageColor()
		imageView.layer.borderColor = ((curImageBackColor.isLight()) ? (UIColor.black.cgColor) : (UIColor.white.cgColor))
		view.backgroundColor = UIColor(patternImage: image)
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		lang = langs[row]
		pickerView.reloadComponent(component)
		for sv in pickerView.subviews where sv is UIImageView {
			sv.removeFromSuperview()
		}
		if let val = dict[lang], let flagIV = val {
			setBackgroundImageToView(view: pickerView, imageView: flagIV)
//			pickerView.backgroundColor = UIColor(patternImage: flagImage)
		} else {
			pickerView.backgroundColor = UIColor(red: 0, green: 172/255, blue: 237/255, alpha: 1.0)
		}
	}
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            tweetSearchText = text
        }
        getTweets()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
