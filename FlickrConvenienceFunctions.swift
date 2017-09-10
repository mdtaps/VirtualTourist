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
    
    func retrieve(picturesFor pin: MKAnnotation, completionHanderForRetrieve: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        
        populatePin(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude) { (response) in
            
            switch response {
            case .Failure(let message):
                completionHanderForRetrieve(false, message)
                print("Failure")
            case .Success(let _):
                completionHanderForRetrieve(true, nil)
                //TODO: Return success or failure
                /*      populatePhoto() {
                 if success, start loading photos
                 if failure, populate ui alert with error message
                 */
            }
        }
    }
    
    func populatePin(latitude: Double, longitude: Double, completionHandlerForPopulate: @escaping (Response<[URL]>) -> Void) {
        
        func sendError(withMessage message: String) {
            completionHandlerForPopulate(.Failure(errorMessage: message))
        }
        
        parameters = [FlickrConstants.URLParameterKeys.Latitude: String(latitude),
                      FlickrConstants.URLParameterKeys.Longitude: String(longitude)]
        
        flickrGETTask() { (dataResponse) in
            
            switch dataResponse {
            case .Failure(let errorMessage):
                sendError(withMessage: errorMessage)
            case .Success(let data):
                self.urls = [URL]()
                
                let parsedData = GeneralNetworkingClient.jsonObjectFromJsonData(data)
                
                guard let photos = parsedData?[FlickrConstants.JSONResponseKeys.Photos] as? [String: AnyObject] else {
                    sendError(withMessage: "Could not find \"photos\" in \(String(describing: parsedData))")
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
                    
                    self.urls.append(GeneralNetworkingClient.jpegURLFromFlickrResponse(urlElements: urlElements))
                    
                    completionHandlerForPopulate(.Success(with: self.urls))
                    
                }
            }

        }
        
    }
}
