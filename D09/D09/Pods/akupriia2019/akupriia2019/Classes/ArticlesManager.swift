//
//  ArticlesManager.swift
//  akupriia2019
//
//  Created by Artem Kupriianets on 1/25/19.
//

import Foundation
import CoreData

final public class ArticleManager {
    static public let shared = ArticleManager()
    var managedObjectContext:NSManagedObjectContext
    var privateContext:NSManagedObjectContext
    
    init() {
        let modelURL = Bundle(for: ArticleManager.self).url(forResource: "article", withExtension:"momd")!
        let mom = NSManagedObjectModel(contentsOf:modelURL)!
        managedObjectContext = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
        privateContext = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel:mom)
        privateContext.persistentStoreCoordinator = coordinator
        managedObjectContext.parent = privateContext
        let options = [NSMigratePersistentStoresAutomaticallyOption:true,NSInferMappingModelAutomaticallyOption:true]
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in:.userDomainMask).last
        let storeURL = documentsURL!.appendingPathComponent("statisticsModel.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName:nil, at:storeURL, options:options)
        }
        catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    public func save() {
        if !(managedObjectContext.hasChanges || privateContext.hasChanges) {
            return
        }
        managedObjectContext.performAndWait {
            if self.managedObjectContext.hasChanges {
                do {
                    try self.managedObjectContext.save()
                }
                catch let error {
                    fatalError(error.localizedDescription)
                }
                
                self.privateContext.perform {
                    do {
                        try self.privateContext.save()
                    }
                    catch let error {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    public func newArticle(title: String?, content: String?, language: String?, image: NSData?) -> Article {
        let art = NSEntityDescription.entity(forEntityName: "Article",
                                             in: managedObjectContext)!
        let a = NSManagedObject(entity: art, insertInto: managedObjectContext) as! Article
        let date = NSDate()
        a.content = content
        a.creationDate = date
        a.image = image
        a.language = language
        a.modificationDate = date
        a.title = title
        save()
        return a
    }
    
    public func removeArticle(_ article: Article) {
        managedObjectContext.delete(article)
        save()
    }
    
    public func getAllArticles()->[Article] {
        let req:NSFetchRequest<Article> = Article.fetchRequest()
        do {
            let articles = try managedObjectContext.fetch(req)
            return articles
        }
        catch let error {
            fatalError(error.localizedDescription)
        }
        return []
    }
    
    public func getArticles(withLang lang: String)->[Article] {
        let req:NSFetchRequest<Article> = Article.fetchRequest()
        req.predicate = NSPredicate(format: "language == %@", lang)
        do {
            let articles = try managedObjectContext.fetch(req)
            return articles
        }
        catch let error {
            fatalError(error.localizedDescription)
        }
        return []
    }
    
    public func getArticles(containString str: String)->[Article] {
        let req:NSFetchRequest<Article> = Article.fetchRequest()
        let lang = NSPredicate(format: "language contains[c] %@", str)
        let title = NSPredicate(format: "title contains[c] %@", str)
        let content = NSPredicate(format: "content contains[c] %@", str)
        req.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [lang, title, content])
        do {
            let articles = try managedObjectContext.fetch(req)
            return articles
        }
        catch let error {
            fatalError(error.localizedDescription)
        }
        return []
    }
    
}
