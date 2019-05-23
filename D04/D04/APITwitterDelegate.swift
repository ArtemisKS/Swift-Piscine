import Foundation

protocol APITwitterDelegate : class {
    func processTweet(_ tweets : [Tweet])
    func processError(_ error : NSError)
}
