//
//  GeneralNetworkingClient.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 9/3/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation

class GeneralNetworkingClient: NSObject {
    
    static func jsonObjectFromJsonData(_ data: Data) -> AnyObject? {
        
        let jsonObject: AnyObject?
        
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        return jsonObject
    }
    
    //Picture URL is retrieved from https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
    static func jpegURLFromFlickrResponse(urlElements: URLElements) -> URL {
        let urlString = "https://farm\(urlElements.farmId).staticflickr.com/\(urlElements.serverId)/\(urlElements.id)_\(urlElements.secret).jpg"
    
    }
}

struct URLElements {
    
    let farmId: String
    let serverId: String
    let id: String
    let secret: String
    
    init(farmId: String, serverId: String, id: String, secret: String) {
        self.farmId = farmId
        self.serverId = serverId
        self.id = id
        self.secret = secret
    }
}
