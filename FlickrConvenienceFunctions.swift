//
//  FlickrConvenienceFunctions.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 9/3/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension FlickrClient {
    
    func retrieve(picturesFor pin: MKAnnotation?, picturesAt pageNumber: Int, completionHanderForRetrieve: @escaping (_ result: UrlResult) -> Void) {
        
        guard let pin = pin else {
            completionHanderForRetrieve(UrlResult.Failure(errorMessage: "Pin not set"))
            return
        }
        
        populatePin(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, page: pageNumber) { (result) in
            
            completionHanderForRetrieve(result)
        }
    }
    
    func populatePin(latitude: Double, longitude: Double, page: Int, completionHandlerForPopulate: @escaping (_ result: UrlResult) -> Void) {
        
        func sendError(withMessage message: String) {
            completionHandlerForPopulate(.Failure(errorMessage: message))
        }
        
        urlParameters[FlickrConstants.URLParameterKeys.Latitude] = String(latitude)
        urlParameters[FlickrConstants.URLParameterKeys.Longitude] = String(longitude)
        urlParameters[FlickrConstants.URLParameterKeys.Page] = String(page)
        
        flickrGETTask() { (dataResponse) in
            
            switch dataResponse {
            case .Failure(let errorMessage):
                sendError(withMessage: errorMessage)
            case .Success(let data):
                var urls = [URL]()
                
                let parsedData = GeneralNetworkingClient.jsonObjectFromJsonData(data)
                
                guard let photos = parsedData?[FlickrConstants.JSONResponseKeys.Photos] as? [String: AnyObject] else {
                    sendError(withMessage: "Could not find \"photos\" in \(String(describing: parsedData))")
                    return
                }
                
                guard let pages = photos[FlickrConstants.JSONResponseKeys.Pages] as? NSNumber else {
                    sendError(withMessage: "Could not find \"pages\" in \(String(describing: parsedData))")
                    return
                }
                
                guard let perPage = photos[FlickrConstants.JSONResponseKeys.Perpage] as? NSNumber else {
                    sendError(withMessage: "Could not find \"perpage\" in \(String(describing: parsedData))")
                    return
                }
                
                guard let photo = photos[FlickrConstants.JSONResponseKeys.Photo] as? [[String:AnyObject]] else {
                    sendError(withMessage: "Could not find \"photo\" in \(dump(photos))")
                    return
                }
                
                for dict in photo {
                    guard let id = dict[FlickrConstants.JSONResponseKeys.Id] as? String else {
                        sendError(withMessage: "Could not find \"id\" in \(dump(dict))")
                        return
                    }
                    
                    guard let secret = dict[FlickrConstants.JSONResponseKeys.Secret] as? String else {
                        sendError(withMessage: "Could not find \"secret\" in \(dump(dict))")
                        return

                    }
                    
                    guard let farmId = dict[FlickrConstants.JSONResponseKeys.Farm] else {
                        sendError(withMessage: "Could not find \"farm\" in \(dump(dict))")
                        return
                    }
                    
                    guard let serverId = dict[FlickrConstants.JSONResponseKeys.Server] as? String else {
                        sendError(withMessage: "Could not find \"server\" in \(dump(dict))")
                        return
                    }
                    
                    let urlElements = URLElements(farmId: String(describing: farmId), serverId: serverId, id: id, secret: secret)
                    
                    if let url = GeneralNetworkingClient.jpegURLFromFlickrResponse(urlElements: urlElements) {
                        urls.append(url)

                    } else {
                        continue
                    }
                }
                
                completionHandlerForPopulate(.Success(urls: urls, numberOfPages: pages as Int, perPage: perPage as Int))
            }

        }
        
    }
}
