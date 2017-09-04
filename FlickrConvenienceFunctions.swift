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
        
        populatePin(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude) { (success, error) in
            
            //TODO: Return success or failure
            /*      populatePhoto() {
             if success, start loading photos
             if failure, populate ui alert with error message
             */
        }
    }
    
    func populatePin(latitude: Double, longitude: Double, completionHandlerForPopulate: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        func sendError(withMessage message: String) {
            completionHandlerForPopulate(false, NSError(domain: "populatePin", code: 1, userInfo: [NSLocalizedDescriptionKey: message]))
        }
        
        //TODO: Retrieve JSON Data and parse
        flickrGETTask { (dataRequest) in
            
            switch dataRequest {
            case .Failure(let statusCode, let errorMessage):
                break
            case .Success(let data):
                let parsedData = GeneralNetworkingClient.jsonObjectFromJsonData(data)
                
                guard let photos = parsedData?[FlickrConstants.JSONResponseKeys.Photos] as? [String: AnyObject] else {
                    sendError(withMessage: "Could not find \"photos\" in \(dump(parsedData))")
                }
                
                guard let photo = photos[FlickrConstants.JSONResponseKeys.Photo] as? ([String:String]) else {
                    sendError(withMessage: "Could not find \"photo\" in \(dump(photos))")
                }
                
                for dict in photo {
                    guard let id = dict[FlickrConstants.JSONResponseKeys.Id] as? String else {
                        sendError(withMessage: "Could not find \"id\" in \(dump(dict))")
                    }
                    
                    guard let secret = dict[FlickrConstants.JSONResponseKeys.Secret] as? String else {
                        sendError(withMessage: "Could not find \"secret\" in \(dump(dict))")

                    }
                    
                    guard let farmId = dict[FlickrConstants.JSONResponseKeys.Farm] as? String else {
                        sendError(withMessage: "Could not find \"farm\" in \(dump(dict))")
                    }
                    
                    guard let serverId = dict[FlickrConstants.JSONResponseKeys.Server] as? String else {
                        sendError(withMessage: "Could not find \"server\" in \(dump(dict))")
                    }
                    
                    let urlElements = URLElements(farmId: farmId, serverId: serverId, id: id, secret: secret)
                    
                    let url = GeneralNetworkingClient.jpegURLFromFlickrResponse(urlElements: urlElements)
                    
                    //TODO: Populate Pin Photo Entity

                }
            }
                

        }
        
    }
}
