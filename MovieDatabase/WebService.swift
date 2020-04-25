//
//  WebService.swift
//  MovieDatabase
//
//  Created by Steven Fellows on 4/24/20.
//  Copyright © 2020 Steven Fellows. All rights reserved.
//

import Foundation
import SystemConfiguration

class WebService: NSObject {
    
    static let baseURL = URL(string: "http://www.omdbapi.com/")
    
    func getSearchResultsData(for searchValue: String, filter: showType, movie completion: @escaping (_ data: Data?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, let baseURL = WebService.baseURL else {
                completion(nil)
                return
            }
            let sessionConfiguration = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfiguration)

            var parameters = [String : String]()
            parameters["s"] = searchValue.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "+")
            if filter != .none {
                parameters["type"] = filter.rawValue
            }
            parameters["apikey"] = "925fc6b5"
        
            let url = self.add(parameters, to: baseURL)
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                completion(data)
            })
            task.resume()
        }
    }

    private func add(_ queryParameters: [String : String], to url: URL) -> URL {
        guard queryParameters.values.count > 0,
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        var queryItems = [URLQueryItem]()
        for (key, value) in queryParameters {
            let item = URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
            
            queryItems.append(item)
        }
        
        urlComponents.queryItems = queryItems
        
        guard let updatedURL = urlComponents.url else { return url }
        return updatedURL
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }

}

