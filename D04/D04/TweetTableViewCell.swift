import UIKit

class
TweetTableViewCell: UITableViewCell {

    

    @IBOutlet weak var title: UILabel!

    @IBOutlet weak var dateTweet: UILabel!
   
    @IBOutlet weak var content: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
