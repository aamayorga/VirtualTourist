//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Ansuke on 3/27/18.
//  Copyright © 2018 AM. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "photoAlbumVC") as! PhotoAlbumViewController
        
        // Add annotation
        let annotation = PhotoPin()
        annotation.coordinate = view.annotation!.coordinate
        print(annotation.coordinate)
        photoAlbumVC.annotation = annotation
        
        navigationController?.pushViewController(photoAlbumVC, animated: true)
    }
    
    @IBAction func editPins(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)

        let annotation = PhotoPin()
        annotation.coordinate = locationCoordinate

        self.mapView.addAnnotation(annotation)
        
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
    }
}
