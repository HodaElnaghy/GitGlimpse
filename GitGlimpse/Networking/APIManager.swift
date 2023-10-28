//
//  APIManager.swift
//  GitGlimpse
//
//  Created by Hoda Elnaghy on 10/25/23.
//

import Foundation
import Alamofire
import Connectivity
import SystemConfiguration

class APIManager {
    static let shared = APIManager()
    
    private init(){}
    
    func request<T: Codable>(
        _ method: HTTPMethod,
        _ url: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        completionHandler: @escaping (Result<T, Error>) -> Void
    ){
        AF.request(url, method: method, parameters: parameters, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let data = response.data {
                        do {
                            let decoder = JSONDecoder()
                            let apiResponse = try
                            decoder.decode(T.self, from: data)
                            completionHandler(.success(apiResponse))
                        } catch {
                            completionHandler(.failure(error))
                        }
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    func isOnline() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return isReachable && !needsConnection
    }

}
