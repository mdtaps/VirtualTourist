//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/30/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation

class FlickrClient {
    
    var shared = FlickrClient()
    
    private init() { }
    
    let session = URLSession.shared
    let parameters = [String: String]()
    var urlParameters = [FlickrConstants.URLParameterKeys.Method        : FlickrConstants.URLParameterValues.Method,
                         FlickrConstants.URLParameterKeys.APIKey        : FlickrConstants.URLParameterValues.APIKey,
                         FlickrConstants.URLParameterKeys.Radius        : FlickrConstants.URLParameterValues.Radius,
                         FlickrConstants.URLParameterKeys.Format        : FlickrConstants.URLParameterValues.Format,
                         FlickrConstants.URLParameterKeys.NoJsonCallBack: FlickrConstants.URLParameterValues.NoJsonCallBack]
    
    enum DataRequest {
        case Success(data: Data)
        case Failure(statusCode: Int?, errorMessage: String)
    }
    
    func flickrGETTask(_ completionHandlerForGET: @escaping (_ dataRequest: DataRequest) -> Void) {
        guard let request = flickrGETRequest() else {
            completionHandlerForGET(.Failure(statusCode: nil, errorMessage: "Error getting data request"))
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                completionHandlerForGET(.Failure(statusCode: nil, errorMessage: error.localizedDescription))
            }
            
            if let response = response {
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    completionHandlerForGET(.Failure(statusCode: nil, errorMessage: "No status code returned with task"))
                }
                
                if statusCode < 200 || statusCode >= 300 {
                    completionHandlerForGET(.Failure(statusCode: statusCode,
                                                     errorMessage: "Bad Status Code"))
                }
            }
            
            if let data = data {
                completionHandlerForGET(.Success(data: data))
            }
        }
        
        task.resume()
    }

    func flickrGETRequest() -> URLRequest? {
        
        guard let url = flickrURLwith(parameters) else {
            return nil
        }
        
        guard let request = flickrMutableUrlRequestWith(url) else {
            return nil
        }
        
        return request as URLRequest
    }
    
    func flickrURLwith(_ parameters: [String: String]) -> URL? {
        
        var components = URLComponents()
        components.scheme = FlickrConstants.APIConstants.Scheme
        components.host = FlickrConstants.APIConstants.Host
        components.path = FlickrConstants.APIConstants.Path
        var queryItems = [URLQueryItem]()
        
        for (key, value) in urlParameters {
            queryItems.append(URLQueryItem(name: key, value: value))
            
        }
        
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
            
        }
        
        components.queryItems = queryItems

        return components.url
    }
    
    //Add Header Values to request
    func flickrMutableUrlRequestWith(_ url: URL) -> NSMutableURLRequest? {
        
        let request = NSMutableURLRequest(url: url)
        request.addValue(FlickrConstants.HTTPHeaderValues.ContentType,
                         forHTTPHeaderField: FlickrConstants.HTTPHeaderKeys.ContentType)
        
        return request
    }
}
