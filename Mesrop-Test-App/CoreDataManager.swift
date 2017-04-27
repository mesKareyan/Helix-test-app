//
//  CoreDataStack.swift
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/26/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    func saveNews(items news: [NewsItem]) {
        news.forEach { insertNewsObjectsFor(news:  $0)}
    }
    
    func makeNewsRead(news: NewsItemEntity) {
        news.isRead = true
        self.saveContext()
    }
    
    private func insertNewsObjectsFor(news: NewsItem) {
        //use shareurl as id for DB
        guard !news.shareUrl.isEmpty else {
            return
        }
        let context = self.persistentContainer.viewContext
        let fetch: NSFetchRequest<NewsItemEntity> = NewsItemEntity.fetchRequest()
        let predicate   = NSPredicate(format: "shareUrl == %@", news.shareUrl)
        fetch.predicate = predicate;
        
        //check for dulicates
        if let count = try? context.count(for: fetch),
            count > 0 {
            return
        }
        
        let newsEntity = NewsItemEntity(context: context)

        newsEntity.date       = NSDate()
        newsEntity.date       = news.date as NSDate? ?? NSDate()
        newsEntity.title      = news.title
        newsEntity.category   = news.category
        newsEntity.body       = news.body
        newsEntity.coverPhotoUrl = news.coverPhotoUrl
        newsEntity.shareUrl = news.shareUrl
        
        for gallery in news.gallery {
            let galleryItem = GalleryItemEntity(context: context)
            galleryItem.title        = gallery.title
            galleryItem.contentUrl   = gallery.contentUrl
            galleryItem.thumbnailUrl = gallery.thumbnailUrl
            galleryItem.newsItem = newsEntity
        }
        // Save the context.
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Mesrop_Test_App")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
