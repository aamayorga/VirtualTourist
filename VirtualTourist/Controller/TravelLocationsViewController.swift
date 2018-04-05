//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Ansuke on 3/27/18.
//  Copyright © 2018 AM. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var deleteMode = false
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    func setUpFetchResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDesc = NSSortDescriptor(key: "longitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setUpFetchResultsController()
        addPinsToMap(fetchedResultsController.fetchedObjects!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpFetchResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    // MARK: Helper
    
    func goToPhotoAlbumView(annotation: MKAnnotation) {
        let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "photoAlbumVC") as! PhotoAlbumViewController
        photoAlbumVC.annotation = annotation
        
        navigationController?.pushViewController(photoAlbumVC, animated: true)
    }
    
    func addPinsToMap(_ pinsArray: [Pin]) {
        for pin in pinsArray {
            let annotation = MKPointIDAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            annotation.id = pin.objectID
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: Saving Pins
    @IBAction func placePin(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        let pointAnnotation = MKPointIDAnnotation()
        
        pointAnnotation.coordinate = locationCoordinate
        
        savePin(pointAnnotation)
        
        mapView.addAnnotation(pointAnnotation)
    }
    
    func savePin(_ point: MKPointIDAnnotation) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = point.coordinate.latitude
        pin.longitude = point.coordinate.longitude
        
        do {
            try dataController.viewContext.save()
            
            point.id = pin.objectID    // ID will not be the same if set before context is saved
        } catch {
            print("Failed to save data")
        }
    }
    
    
    // MARK: Removing Pins
    
    @IBAction func editPins(_ sender: UIBarButtonItem) {
        print("Edit Button tapped")
        deleteMode = !deleteMode
    }
    
    func deletePin(_ annotationView: MKAnnotationView) {
        guard let pointAnnotation = annotationView.annotation as! MKPointIDAnnotation? else {
            print("Couldn't type cast MKAnnotationView's annotation to Point Annotation")
            return
        }
        
        let pinToDelete = fetchedResultsController.managedObjectContext.object(with: pointAnnotation.id)
        dataController.viewContext.delete(pinToDelete)

        do {
            try dataController.viewContext.save()
            mapView.removeAnnotation(annotationView.annotation!)
        } catch {
            print("Failed to save (deleted) data")
        }
    }
}

// MARK: Map View Delegate Methods
extension TravelLocationsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if deleteMode {
            deletePin(view)
        } else {
            goToPhotoAlbumView(annotation: view.annotation!)
        }
    }
}

// MARK: Fetched Result Controller Delegate Methods
extension TravelLocationsViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            break
        case .delete:
            break
        default:
            fatalError("Unsupported behavior called")
        }
    }
}
