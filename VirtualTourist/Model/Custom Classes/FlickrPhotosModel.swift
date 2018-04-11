//
//  FlickrPhotosModel.swift
//  VirtualTourist
//
//  Created by Ansuke on 4/10/18.
//  Copyright © 2018 AM. All rights reserved.
//

import Foundation

struct FlickrResults: Decodable {
    let photos: FlickrPhotos
    let stat: String
}

struct FlickrPhotos: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [FlickrPhoto]
}

struct FlickrPhoto: Decodable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    let url: String?
    let height: String?
    let width: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
        case url = "url_m"
        case height = "height_m"
        case width = "width_m"
    }
}
