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
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet var addPinLongPressGesture: UILongPressGestureRecognizer!
    
    var deleteMode = false
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    func setUpFetchResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDesc = NSSortDescriptor(key: "longitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setUpFetchResultsController()
        setMapSpan()
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
        deleteMode = !deleteMode
        deleteLabel.isHidden = !deleteLabel.isHidden
        addPinLongPressGesture.isEnabled = !addPinLongPressGesture.isEnabled
    }
    
    func deletePin(_ annotationView: MKAnnotationView) {
        guard let pointAnnotation = annotationView.annotation as! MKPointIDAnnotation? else {
            print("Couldn't type cast MKAnnotationView's annotation to custom MKPointIDAnnotation")
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
    
    // MARK: Persist Map Zoom
    func setMapSpan() {
        guard let regionCenterLatitude = UserDefaults.standard.value(forKey: "regionCenterLatitude") as? Double,
            let regionCenterLongitude = UserDefaults.standard.value(forKey: "regionCenterLongitude") as? Double,
            let regionSpanLatitude = UserDefaults.standard.value(forKey: "regionSpanLatitude") as? Double,
            let regionSpanLongitude = UserDefaults.standard.value(forKey: "regionSpanLongitude") as? Double else {
            print("First time booting app")
            return
        }
        
        mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: regionCenterLatitude, longitude: regionCenterLongitude), MKCoordinateSpan(latitudeDelta: regionSpanLatitude, longitudeDelta: regionSpanLongitude)), animated: false)
    }
    
    func saveMapSpan() {
        let region = mapView.region
        
        UserDefaults.standard.set(region.center.latitude, forKey: "regionCenterLatitude")
        UserDefaults.standard.set(region.center.longitude, forKey: "regionCenterLongitude")
        UserDefaults.standard.set(region.span.latitudeDelta, forKey: "regionSpanLatitude")
        UserDefaults.standard.set(region.span.longitudeDelta, forKey: "regionSpanLongitude")
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

