//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Ansuke on 3/29/18.
//  Copyright © 2018 AM. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private let reuseIdentifier = "photoCellReuseIdentifier"

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionOrDeletionBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var pin: Pin!
    var annotation: MKPointIDAnnotation!
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var currentPage = 1
    var numberOfPlaceholders = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        mapView.addAnnotation(annotation)
        mapView.isUserInteractionEnabled = false
        mapView.setRegion(MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
        
        let space: CGFloat = 3.0
        let dimension = (photoCollectionView.frame.size.width - (2 * space)) / 3.0
        
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        pin = dataController.viewContext.object(with: annotation.id) as? Pin
        setupFetchedResultsController()
        
        // Check if pin has pictures array
        if fetchedResultsController.fetchedObjects?.count == 0 {
            getNewSetOfPictures()
            return
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    @IBAction func getNewCollectionOfPhotosOrDeletion(_ sender: UIBarButtonItem) {
        if (sender.title == "New Collection") {
            deleteAllPictures()
            showResults()
            getNewSetOfPictures()
        } else {
            deletePictures()
            showResults()
        }
        
    }
    
    func showResults() {
        
        DispatchQueue.main.async {
            
            self.photoCollectionView.reloadData()
        }
    }
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func getNewSetOfPictures() {
        
        let flickrClient = FlickrClient()
        flickrClient.getNewSetOfFlickrPictures(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, pageNumber: currentPage) { (success, data, error) in
            
            func sendError(_ error: String) {
                self.photoCollectionView.isHidden = true
                self.noImagesLabel.isHidden = false
                print(error)
            }
            
            guard error == nil else {
                sendError(error!)
                return
            }
            
            self.currentPage = self.currentPage + 1
            
            if (success) {
                guard let flickrResults = data as? FlickrResults else {
                    sendError("Could convert data to encodable Flickr data")
                    return
                }
                
                self.toggleUI()
            
                self.addPlaceholder(flickrResults.photos.photo.count)
                
                flickrClient.parsePictures(fromResults: flickrResults, completionHandlerForPhoto: { (imageData) in
                    self.savePicture(imageData)
                })
                self.showResults()
                
                DispatchQueue.main.async {
                    if self.photoCollectionView.numberOfItems(inSection: 0) == 0 {
                        self.noImagesLabel.isHidden = false
                    }
                }
                
                self.toggleUI()
            }
        }
    }
    
    func addPlaceholder(_ placeholders: Int) {
        
        numberOfPlaceholders = placeholders
        
        if numberOfPlaceholders > 21 {
            numberOfPlaceholders = 21
        }
        
        showResults()
        
    }
    
    func savePicture(_ imageData: Data) {
        let pictures = Photo(context: dataController.viewContext)
        pictures.pin = pin
        pictures.photo = imageData
        do {
            try dataController.viewContext.save()
        } catch {
            print("Could not save picture")
        }
    }
    
    func deletePictures() {
        
        guard let selectedItems = photoCollectionView.indexPathsForSelectedItems else {
            print("Index paths for selected items property is nil")
            return
        }
        
        newCollectionOrDeletionBarButton.title = "New Collection"
        for index in selectedItems {
            let photo = fetchedResultsController.object(at: index)
            dataController.viewContext.delete(photo)
            photoCollectionView.deselectItem(at: index, animated: false)
            
            let selectedCell = photoCollectionView.cellForItem(at: index) as? PhotoCollectionViewCell
            selectedCell?.imageView.alpha = 1
        }
        try? dataController.viewContext.save()
    }
    
    func deleteAllPictures() {
        let objects = fetchedResultsController.fetchedObjects!
        for object in objects {
            dataController.viewContext.delete(object)
        }
        try? dataController.viewContext.save()
    }
    
    func toggleUI() {
        DispatchQueue.main.async {
            self.photoCollectionView.isUserInteractionEnabled = !self.photoCollectionView.isUserInteractionEnabled
            self.newCollectionOrDeletionBarButton.isEnabled = !self.newCollectionOrDeletionBarButton.isEnabled
        }
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            numberOfPlaceholders = 0
        default:
            print("Unimplemented default action")
        }
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.allowsMultipleSelection = true
        
        if fetchedResultsController.sections![section].numberOfObjects == 0 && numberOfPlaceholders != 0 {
            return numberOfPlaceholders
        }
        print("Number of Items in section: ", fetchedResultsController.sections?[section].numberOfObjects)
        return fetchedResultsController.sections?[section].numberOfObjects ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        if numberOfPlaceholders != 0 {
            cell.imageView.image = #imageLiteral(resourceName: "loading")
            cell.imageView.backgroundColor = UIColor.black
        } else {
            let photoData = fetchedResultsController.object(at: indexPath).photo
            let photo = UIImage(data: photoData!)

            cell.imageView.image = photo
        }
        
        return cell
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell
        selectedCell?.imageView.alpha = 0.25
        
        newCollectionOrDeletionBarButton.title = "Remove Selected Pictures"
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell
        selectedCell?.imageView.alpha = 1
        
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if (selectedItems.count == 0) {
                newCollectionOrDeletionBarButton.title = "New Collection"
            }
        }
    }
}
