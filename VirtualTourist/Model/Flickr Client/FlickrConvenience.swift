//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Ansuke on 4/9/18.
//  Copyright © 2018 AM. All rights reserved.
//

import Foundation
import UIKit

extension FlickrClient {
    func getNewSetOfFlickrPictures(latitude: Double, longitude: Double, completionHandlerForNewSetOfFlickrPictures: @escaping (_ success: Bool, _ pictures: [UIImage]?, _ errorString: String?) -> Void) {
        
        let methodParameters = [FlickrParameterKeys.Method: FlickrParameterValues.PhotosSearch,
                                FlickrParameterKeys.ApiKey: FlickrParameterValues.ApiKey,
                                FlickrParameterKeys.Extras: FlickrParameterValues.Extras,
                                FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
                                FlickrParameterKeys.NoJsonCallback: FlickrParameterValues.DisableJsonCallback,
                                FlickrParameterKeys.Latitude: String(latitude),
                                FlickrParameterKeys.Longitude: String(longitude)]
        
        taskForGETMethod(methodParameters: methodParameters) { (data, error) in
            func sendError(_ error: String) {
                print(error)
            }
            
            guard error == nil else {
                sendError("There was an error.")
                return
            }
            
            guard let data = data else {
                sendError("Data is nil")
                return
            }
            
            let flickrResults = data as! FlickrResults
            
            guard let photos = self.parsePictures(fromResults: flickrResults) else {
                completionHandlerForNewSetOfFlickrPictures(false, nil, "Could not get new pictures")
                return
            }
            
            completionHandlerForNewSetOfFlickrPictures(true, photos, nil)
        }
        
        
    }
    
    func parsePictures(fromResults results: FlickrResults) -> [UIImage]? {
        var photosArray: [UIImage] = []
        
        for photoDetails in results.photos.photo {
            
            if photosArray.count >= 21 {
                break
            }
            
            let url = URL(string: photoDetails.url!)
            
            var data: Data
            do {
                data = try Data(contentsOf: url!)
            } catch {
                print("Could not convert url to data")
                return nil
            }
            
            let photo = UIImage(data: data)
            photosArray.append(photo!)
            
            
        }
        
        return photosArray
    }
}
