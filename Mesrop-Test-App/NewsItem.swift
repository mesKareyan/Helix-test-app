//
//  NewsItem.swift
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/25/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import Foundation

struct NewsItem {
    
    let category:       String
    let title:          String
    let body:           String
    let shareUrl:       String
    let coverPhotoUrl:  String
    var date:           Date?
    let gallery:        [GalleryItem]
    
    init(with data: [String: Any]) {
         category       = data["category"]      as? String ?? ""
         title          = data["title"]         as? String ?? ""
         body           = data["body"]          as? String ?? ""
         shareUrl       = data["shareUrl"]      as? String ?? ""
         coverPhotoUrl  = data["coverPhotoUrl"] as? String ?? ""
         if let timestamp = data["date"] as? Double {
            date = Date(timeIntervalSince1970: timestamp)
         }
        if let galleryData = data["gallery"] as? [[String: String]] {
            gallery = galleryData.map { data in GalleryItem(with: data) }
        } else {
            gallery = []
        }
    }
    
}

struct GalleryItem {
    
    let title:          String
    let thumbnailUrl:   String
    let contentUrl:     String
    
    init(with data: [String: String]) {
        title        = data["title"]        ?? ""
        thumbnailUrl = data["thumbnailUrl"] ?? ""
        contentUrl   = data["contentUrl"]   ?? ""
    }
    
}
