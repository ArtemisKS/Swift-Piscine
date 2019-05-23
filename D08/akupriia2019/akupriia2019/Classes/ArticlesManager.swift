//
//  ArticlesManager.swift
//  akupriia2019
//
//  Created by Artem Kupriianets on 1/25/19.
//

import Foundation
import CoreData

public class ArticleManager {
    
    var managedObjectContext: NSManagedObjectContext
    
    public init() {
        let myBundle = Bundle(identifier: "org.cocoapods.akupriia2019")
        guard let modelURL = myBundle?.url(forResource: "article", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: model url")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
//        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
//        queue.async {
            guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
                fatalError("Unable to resolve document directory")
            }
            let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
            } catch {
                fatalError("Error migrating store: \(error)")
            }
//    }
    }

    public func newArticle() -> Article {
        return NSEntityDescription.insertNewObject(forEntityName: "Article", into: self.managedObjectContext) as! Article
    }

    public func getAllArticles() -> [Article] {
        var articles: [Article] = []
        do {
            articles = try self.managedObjectContext.fetch(Article.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return articles
    }

    public func getArticles(withLang lang: String) -> [Article] {
        var articles: [Article] = []        
        do {
            let request = NSFetchRequest<Article>(entityName: "Article")
            request.predicate = NSPredicate(format: "language == %@", lang)
            articles = try self.managedObjectContext.fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return articles
    }

    public func getArticles(containsString str: String) -> [Article]{
        var articles: [Article] = []
        do {
            let request = NSFetchRequest<Article>(entityName: "Article")
            request.predicate = NSPredicate(format: "content CONTAINS[c] %@", str)
            articles = try self.managedObjectContext.fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return articles
    }

    public func removeArticle(article: Article) {

        do {
            self.managedObjectContext.delete(article)
            try self.managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }

    public func save() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
}
