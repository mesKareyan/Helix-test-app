//
//  DetailViewController.swift
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/25/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class NewsDetailViewController: UIViewController {
    
    @IBOutlet weak var newsImageView:           UIImageView!
    @IBOutlet var      thumbnailImages:         [UIImageView]!
    @IBOutlet weak var galleryPlusImageView:    UIImageView!
    @IBOutlet weak var newsWebView:             UIWebView!
    @IBOutlet weak var titleLabel:              UILabel!
    @IBOutlet weak var categoryLabel:           UILabel!
    @IBOutlet weak var galleryItemsView:        UIView!
    @IBOutlet weak var topView:                 UIView!
    @IBOutlet weak var titleView:               UIView!
    @IBOutlet weak var topViewTopConstraint: NSLayoutConstraint!
    
    var lastTopOffsetY: CGFloat = 0
    let navBarHeight: CGFloat = 60
    var newsItem: NewsItemEntity? {
        didSet {
            // Update the view.
            if self.isViewLoaded {
                configureView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsWebView.scrollView.delegate = self;
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
    override var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
    }
    
    func configureView() {
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let offset = CGPoint(x: 0, y: navBarHeight)
        newsWebView.scrollView.contentInset = insets
        newsWebView.scrollView.scrollIndicatorInsets = insets
        newsWebView.scrollView.setContentOffset(offset, animated: false)
        newsWebView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Update the user interface for the news item.
        if let news = self.newsItem {
            //news title ui
            titleLabel.text = news.title
            if let catagory = news.category {
                self.title = " / " + catagory
            }
            self.categoryLabel.text = news.date?.shortString
            //news main cover Image
            if let urlString = news.coverPhotoUrl {
                let url = URL(string: urlString)!
                self.newsImageView.hnk_setImageFromURL(url)
            }
            //news text content
            if let body = news.body {
                newsWebView.loadHTMLString(body, baseURL: nil)
            }
            //news thumbnail images
            guard let galleryItems = news.gallery, galleryItems.count > 0 else {
                galleryItemsView.isHidden = true
                return
            }
            //get all gallery items array and show max 3 items
            var galleryArray: Array<GalleryItemEntity> = Array(galleryItems) as! Array<GalleryItemEntity>
            var items = [GalleryItemEntity]()
            var itemsCount = 0
            while itemsCount < 3 && itemsCount < galleryArray.count {
                items.append(galleryArray[itemsCount])
                itemsCount += 1
            }
            // hide extra thumbnails container views
            for index in itemsCount..<3 {
                let thumbnailImage =  thumbnailImages[index]
                thumbnailImage.superview!.isHidden = true
            }
            //show images
            for (index, item ) in items.enumerated() {
                if let thumbnailUrlString = item.thumbnailUrl,
                    let  thumbnailUrl = URL(string: thumbnailUrlString) {
                    let thumbnailImage = thumbnailImages[index]
                    thumbnailImage.hnk_setImageFromURL(thumbnailUrl)
                }
            }
        }
    }
    
    @IBAction func moreButtonTapped(_ sender: UITapGestureRecognizer) {
        showGallery()
    }
    
    //MARK: - Gallery images
    
    func showGallery() {
        guard let news = newsItem,
            let galleryItems = news.gallery as? Set<GalleryItemEntity>  else {
                return
        }
        // 1. create URL Array
        var images = [SKPhoto]()
        for galleryItem in galleryItems {
            if let photoUrl = galleryItem.contentUrl {
                let photo = SKPhoto.photoWithImageURL(photoUrl)
                photo.shouldCachePhotoURLImage = false // you can use image cache by true(NSCache)
                images.append(photo)
            }
        }
        
        // 2. create PhotoBrowser Instance, and present.
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(0)
        //configure Browser
        browser.title = news.title
        present(browser, animated: true, completion: {})
    }
    
}

//MARK: - ScrollView delegate
extension NewsDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === newsWebView.scrollView else {
            return
        }
        guard let _ = self.navigationController?.navigationBar else {
            return
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView === newsWebView.scrollView {
            self.lastTopOffsetY = scrollView.contentOffset.y;
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === newsWebView.scrollView {
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView === newsWebView.scrollView {
            let hide = newsWebView.scrollView.contentOffset.y > lastTopOffsetY
            setTopView(hidden: hide)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === newsWebView.scrollView {
        }
    }
    
    func setTopView(hidden isHidden: Bool) {
        topViewTopConstraint.constant =  isHidden ? -360 : 0
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
}

