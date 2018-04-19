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
    func getNewSetOfFlickrPictures(latitude: Double, longitude: Double, pageNumber page: Int, completionHandlerForNewSetOfFlickrPictures: @escaping (_ success: Bool, _ data: AnyObject?, _ errorString: String?) -> Void) {
        
        let methodParameters = [FlickrParameterKeys.Method: FlickrParameterValues.PhotosSearch,
                                FlickrParameterKeys.ApiKey: FlickrParameterValues.ApiKey,
                                FlickrParameterKeys.Extras: FlickrParameterValues.Extras,
                                FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
                                FlickrParameterKeys.NoJsonCallback: FlickrParameterValues.DisableJsonCallback,
                                FlickrParameterKeys.Latitude: String(latitude),
                                FlickrParameterKeys.Longitude: String(longitude),
                                FlickrParameterKeys.Page: String(page)]
        
        taskForGETMethod(methodParameters: methodParameters) { (data, error) in
            func sendError(_ errorMessage: String) {
                completionHandlerForNewSetOfFlickrPictures(false, nil, errorMessage)
            }
            
            guard error == nil else {
                sendError("Could not retrieve data")
                return
            }
            
            guard let data = data else {
                sendError("No data was retrieved")
                return
            }
            
            completionHandlerForNewSetOfFlickrPictures(true, data, nil)
        }
    }
    
    func parsePictures(fromResults results: FlickrResults, completionHandlerForPhoto: (_ photo: Data) -> Void) {
        var dataArray: [Data] = []
        
        for photoDetails in results.photos.photo {
            
            if dataArray.count >= 21 {
                break
            }
            
            let url = URL(string: photoDetails.url!)
            
            var data: Data
            do {
                data = try Data(contentsOf: url!)
            } catch {
                print("Could not convert url to data")
                return
            }
            
            dataArray.append(data)
            
            completionHandlerForPhoto(data)
        }
    }
}
