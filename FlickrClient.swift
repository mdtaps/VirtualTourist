//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/30/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation

class FlickrClient {
    
    static var shared = FlickrClient()
    
    private init() { }
    
    let session = URLSession.shared
    
    //TODO: Add parameter to limit amount of URLs downloaded
    var urlParameters = [FlickrConstants.URLParameterKeys.Method        : FlickrConstants.URLParameterValues.Method,
                         FlickrConstants.URLParameterKeys.APIKey        : FlickrConstants.URLParameterValues.APIKey,
                         FlickrConstants.URLParameterKeys.Radius        : FlickrConstants.URLParameterValues.Radius,
                         FlickrConstants.URLParameterKeys.Format        : FlickrConstants.URLParameterValues.Format,
                         FlickrConstants.URLParameterKeys.NoJsonCallBack: FlickrConstants.URLParameterValues.NoJsonCallBack,
                         FlickrConstants.URLParameterKeys.PerPage       : FlickrConstants.URLParameterValues.PerPage]
    
    func flickrGETTask(_ completionHandlerForGET: @escaping (_ dataRequest: Response<Data>) -> Void) {
        guard let request = flickrGETRequest() else {
            completionHandlerForGET(.Failure(errorMessage: "Error getting data request"))
            return
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                completionHandlerForGET(.Failure(errorMessage: error.localizedDescription))
            }
            
            if let response = response {
                guard let code = (response as? HTTPURLResponse)?.statusCode else {
                    completionHandlerForGET(.Failure(errorMessage: "No status code returned with task"))
                    
                    return
                }
                
                let statusCode = StatusCode(code: code)
                
                switch statusCode {
                case .Ok: break
                default:
                    completionHandlerForGET(.Failure(errorMessage: "Request failed and returned status code: \(statusCode)"))
                }
             }
            
            if let data = data {
                completionHandlerForGET(.Success(with: data))
            }
        }
        
        task.resume()
    }

    func flickrGETRequest() -> URLRequest? {
        
        guard let url = flickrURL() else {
            return nil
        }
                
        guard let request = flickrMutableUrlRequestWith(url) else {
            return nil
        }
        
        return request as URLRequest
    }
    
    func flickrURL() -> URL? {
        
        var components = URLComponents()
        components.scheme = FlickrConstants.APIConstants.Scheme
        components.host = FlickrConstants.APIConstants.Host
        components.path = FlickrConstants.APIConstants.Path
        var queryItems = [URLQueryItem]()
        
        for (key, value) in urlParameters {
            queryItems.append(URLQueryItem(name: key, value: value))
            
        }
        
        components.queryItems = queryItems

        return components.url
    }
    
    //Add Header Values to request
    func flickrMutableUrlRequestWith(_ url: URL) -> NSMutableURLRequest? {
        
        let request = NSMutableURLRequest(url: url)
//        request.addValue(FlickrConstants.HTTPHeaderValues.ContentType,
//                         forHTTPHeaderField: FlickrConstants.HTTPHeaderKeys.ContentType)
//        request.httpMethod = "GET"
        
        return request
    }
}

enum StatusCode: CustomStringConvertible {
    case Ok(Int)
    case BadParameters(Int)
    case NotFound(Int)
    case Unknown(Int)
    
    init(code: Int) {
        switch code {
        case 200...299:
            self = .Ok(code)
        case 900...999:
            self = .BadParameters(code)
        case 404:
            self = .NotFound(code)
        default:
            self = .Unknown(code)
        }
    }
    
    var description: String {
        switch self {
        case .Ok(let code):
            return "\(code): Ok"
        case .BadParameters(let code):
            return "\(code): Bad parameters"
        case .NotFound(let code):
            return "\(code): Not Found"
        case .Unknown(let code):
            return "\(code): Unknown status code"
            
        }
    }
}

enum Response<T> {
    case Success(with: T)
    case Failure(errorMessage: String)
}

enum UrlResult {
    case Success(urls: [URL], numberOfPages: Int, perPage: Int)
    case Failure(errorMessage: String)
}
