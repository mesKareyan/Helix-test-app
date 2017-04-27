//
//  NewsListViewController
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/25/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit
import CoreData
import Haneke
import SVProgressHUD

struct Constants {
    
    private init () {}
    enum Segues : String {
        case  showDetail
    }
    struct CellIdentifer {
        private init () {}
        static let newsCell = "newsCell"
    }
    struct AnimationDuration {
        private init() {}
        static let showFirstItemForIPad: TimeInterval = 0.4
    }
    
}

class NewsListViewController: UITableViewController {

    var detailViewController: NewsDetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var fetchedResultsController: NSFetchedResultsController<NewsItemEntity>! = nil
    
    //MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeFetchedResultsController()
        //add table view refresh control action
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        //configure for splitView
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count - 1 ] as! UINavigationController).topViewController as? NewsDetailViewController
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.detailViewController?.view.alpha = 0.0
            }
        }
        loadNews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    func loadNews() {
        SVProgressHUD.show()
        NetworkManager.shared.getAllNews { result in
            SVProgressHUD.dismiss()
            self.updateUIForIpad()
            switch result {
            case .fail(with: let error):
                self.showAlert(for: error)
            case .success(with: let data):
                let news = data as! [NewsItem]
                CoreDataManager.shared.saveNews(items: news)
            }
        }
    }
    
    func updateUIForIpad() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        let initialIndexPath = IndexPath(row: 0, section: 0)
        UIView.transition(with: self.detailViewController!.view, duration: Constants.AnimationDuration.showFirstItemForIPad, options: .curveEaseOut, animations: {
            self.detailViewController!.view.alpha = 1.0
        }, completion: { (finished: Bool) -> () in
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.AnimationDuration.showFirstItemForIPad) {
            self.tableView.selectRow(at: initialIndexPath, animated: true, scrollPosition:UITableViewScrollPosition.none)
            self.performSegue(withIdentifier: Constants.Segues.showDetail.rawValue , sender: self.tableView.cellForRow(at: initialIndexPath))
            self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: initialIndexPath)
        }
    }
    
    func showAlert(for error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    //MARK: - FetchedResultsController
    
    func initializeFetchedResultsController() {
        self.managedObjectContext = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NewsItemEntity> = NewsItemEntity.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: #keyPath(NewsItemEntity.category), cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.showDetail.rawValue {
            if let indexPath = tableView.indexPathForSelectedRow {
            let newsObject = fetchedResultsController.object(at: indexPath)
                CoreDataManager.shared.makeNewsRead(news: newsObject)
                let controller = (segue.destination as! UINavigationController).topViewController as! NewsDetailViewController
                controller.newsItem = newsObject
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

// MARK: - Table View

extension NewsListViewController  {
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let selectedCell = tableView.cellForRow(at: indexPath)
            selectedCell?.contentView.backgroundColor = UIColor.groupTableViewBackground
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == .pad {
         let selectedCell  = tableView.cellForRow(at: indexPath)
         selectedCell?.contentView.backgroundColor = UIColor.white
        }
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifer.newsCell, for: indexPath)
        let newsItem = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withNews: newsItem)
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withNews newsEntity: NewsItemEntity) {
        if let cell = cell as? NewsTableViewCell {
            
            cell.titleLabel.text = " ... "

            if let urlString = newsEntity.coverPhotoUrl {
                let url = URL(string: urlString)!
                cell.thumbnailImageView.hnk_setImageFromURL(url)
            }
            
            cell.unreadCircleView.isHidden = newsEntity.isRead
            if let date = newsEntity.date {
                cell.dateLabel.text = date.shortString
            }
            cell.titleLabel.text = newsEntity.title
        }
    }
}

// MARK: - Fetched results controller delegate

extension NewsListViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            self.tableView.endUpdates()
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // In the simplest, most efficient, case, reload the table view.
        //tableView.reloadData()
    }
    
}

