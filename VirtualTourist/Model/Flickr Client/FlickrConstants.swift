//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Ansuke on 3/27/18.
//  Copyright © 2018 AM. All rights reserved.
//

import Foundation

extension FlickrClient {
    struct FlickrURLComponents {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJsonCallback = "nojsoncallback"
        static let Latitude = "lat"
        static let Longitude = "lon"
    }
    
    struct FlickrParameterValues {
        static let PhotosSearch = "flickr.photos.search"
        static let ApiKey = "6d38011a32449bfbf34693d8952a43bb"
        static let Extras = "url_m"
        static let ResponseFormat = "json"
        static let DisableJsonCallback = "1"
    }
}
