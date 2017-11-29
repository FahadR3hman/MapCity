//
//  Constant.swift
//  MapCity
//
//  Created by Fahad Rehman on 11/29/17.
//  Copyright © 2017 Codecture. All rights reserved.
//

import Foundation

let API_KEY = "499c1983561a2d77144f9605db30714d"
let API_KEY_SECRET = "dd029cf333226210"

func FLIKER_URL (forApiKey : String , forAnnotation annotation: DroppablePin , numOfPhotos photos: Int) -> String {
    
    let finalUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius_units=m&per_page=\(photos)&format=json&nojsoncallback=1"
    return finalUrl
}

let BASE_URL = "1ffeb31811338c89a96a74a9181a58bd&lat=42.8&lon=122.8&radius=1&radius_units=m&per_page=40&format=json&nojsoncallback=1"
