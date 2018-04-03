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
    
    var dataController: DataController!
    var pins: [Pin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
            addPinsToMap(pinsArray: pins)
        }
    }
    
    // MARK: Editing
    
    func savePin(coords: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coords.latitude
        pin.longitude = coords.longitude
        
        do {
            try dataController.viewContext.save()
        } catch {
            print("Failed to save data")
        }
    }
    
    // MARK: Add/Remove Pins
    @IBAction func editPins(_ sender: UIBarButtonItem) {
        print("Edit Button tapped")
    }
    
    @IBAction func placePin(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = locationCoordinate
        self.mapView.addAnnotation(annotation)
        savePin(coords: locationCoordinate)
    }
    
    func addPinsToMap(pinsArray: [Pin]) {
        for pin in pinsArray {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            mapView.addAnnotation(annotation)
        }
    }
}

// MARK: Map View Delegate Methods
extension TravelLocationsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "photoAlbumVC") as! PhotoAlbumViewController
        
        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = view.annotation!.coordinate
        photoAlbumVC.annotation = annotation
        
        navigationController?.pushViewController(photoAlbumVC, animated: true)
    }
}
