//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Ansuke on 3/29/18.
//  Copyright © 2018 AM. All rights reserved.
//

import UIKit
import MapKit

private let reuseIdentifier = "photoCellReuseIdentifier"

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var annotation: MKAnnotation!
    
    var photosArray = [#imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading"), #imageLiteral(resourceName: "loading")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollectionView.dataSource = self
        
        mapView.addAnnotation(annotation)
        mapView.isUserInteractionEnabled = false
        mapView.setRegion(MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
        
        let space: CGFloat = 3.0
        let dimension = (photoCollectionView.frame.size.width - (2 * space)) / 3.0
        
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        let flickrClient = FlickrClient()
        flickrClient.getNewSetOfFlickrPictures(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { (success, photos, error) in
            guard error == nil else {
                print("Error getting pictures")
                return
            }
            
            guard success == true else {
                print("Not successful")
                return
            }
            
            guard photos != nil else {
                print("No photos in array")
                return
            }
            
            DispatchQueue.main.async {
                self.photosArray = photos!
                self.photoCollectionView.reloadData()
            }
            
        }
    }
    
    @IBAction func getNewCollectionOfPhotos(_ sender: UIBarButtonItem) {
        print("New Collection Button tapped")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        let photo = photosArray[indexPath.row]
        
        cell.imageView.image = photo
        cell.imageView.backgroundColor = UIColor.black
        
        return cell
    }
}
