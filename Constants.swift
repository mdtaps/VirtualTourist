//
//  Constants.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/21/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    static let ShiftAmount: CGFloat = 80
    
    struct EntityNames {
        static let Pin = "Pin"
        static let Photo = "Photo"
    }
    
    struct PinAttributeNames {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    struct PhotoAttributeNames {
        static let Photo = "photo"
        static let CreationDate = "creationDate"
    }
}

struct FlickrConstants {
    
    struct APIConstants {
        static let Scheme = "https"
        static let Host = "api.flickr.com"
        static let Path = "/services/rest/"
    }
    
    struct URLParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Radius = "radius"
        static let Format = "format"
        static let Page = "page"
        static let NoJsonCallBack = "nojsoncallback"
        static let PerPage = "per_page"
    }
    
    struct URLParameterValues {
        static let Method = "flickr.photos.search"
        static let APIKey = getAPIKey()
        static let Radius = "1"
        static let Format = "json"
        static let NoJsonCallBack = "1"
        static let PerPage = "21"
    }
    
    struct HTTPHeaderKeys {
        static let ContentType = "Content-Type"
    }
    
    struct HTTPHeaderValues {
        static let ContentType = "application/json"
    }
    
    struct JSONResponseKeys {
        static let Photos = "photos"
        
        static let Page = "page"
        static let Pages = "pages"
        static let Perpage = "perpage"
        static let Total = "total"
        static let Photo = "photo"
        
        static let Id = "id"
        static let Secret = "secret"
        static let Server = "server"
        static let Farm = "farm"
    }
}

fileprivate func getAPIKey() -> String {
     if let path = Bundle.main.path(forResource: "APIKeyPropertyList", ofType: "plist"),
        let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
        
        if let key = dict["FlickrAPIKey"] as? String {
            return key
        }
        
    }
    
    fatalError("Couldn't get API Key")
}
