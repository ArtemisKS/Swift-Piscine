//
//  ViewController.swift
//  akupriia2019
//
//  Created by ArtemisKS on 04/12/2019.
//  Copyright (c) 2019 ArtemisKS. All rights reserved.
//

import UIKit
import CoreData
import akupriia2019

class ViewController: UIViewController {
    
    var articleMan = ArticleManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let newArticle = articleMan.newArticle()
        newArticle.content = "Content of 1st article"
        newArticle.creationDate = Date() as NSDate
        newArticle.modificationDate = Date() as NSDate
        newArticle.title = "Article 1"
        newArticle.language = "en"
        if let img = UIImage(named: "ak_pisa") {
            newArticle.image = UIImagePNGRepresentation(img) as NSData?
        }
        articleMan.save()
        
        let newArticle2 = articleMan.newArticle()
        newArticle2.content = "Content of 2nd article"
        newArticle2.creationDate = Date() as NSDate
        newArticle2.modificationDate = Date() as NSDate
        newArticle2.title = "Article 2"
        newArticle2.language = "en"
        if let img = UIImage(named: "ak_colosseo") {
            newArticle2.image = UIImagePNGRepresentation(img) as NSData?
        }
        articleMan.save()
        
        let newArticle3 = articleMan.newArticle()
        newArticle3.content = "je n'aime pas la Core Data"
        newArticle3.creationDate = Date() as NSDate
        newArticle3.modificationDate = Date() as NSDate
        newArticle3.title = "French one"
        newArticle3.language = "fr"
        if let img = UIImage(named: "nature") {
            newArticle3.image = UIImagePNGRepresentation(img) as NSData?
        }
        articleMan.save()
        
        let all = articleMan.getAllArticles()
        let french = articleMan.getArticles(withLang: "fr")
        let search = articleMan.getArticles(containsString: "2nd")
        
        for (ind, art) in all.enumerated() {
            print("title of article #\(ind + 1): ", art.title ?? "none")
        }
        let str = String(repeating: "-", count: 20)
        print("<\(str)>")
        
        for art in french {
            print("French article title: ", art.title ?? "none")
        }
        print("<\(str)>")
        
        for art in search {
            print("Search result: ", art.title ?? "none")
        }
        
        print("<\(str)>")
        
        for art in all {
            articleMan.removeArticle(article: art)
        }
        
        let all2 = articleMan.getAllArticles()
        
        print("all2: ", all2)
        
    }
}
