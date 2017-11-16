//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by 王靖凯 on 2017/11/16.
//  Copyright © 2017年 王靖凯. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    
    private init() {}
    
    static let shared = { () -> NetworkManager in
        let instance = NetworkManager()
        return instance
    }()
    
    public func get(urlString: String, parameters: [String: Any]?) {
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(let data):
                console.debug(data)
            case .failure(let e):
                console.debug(e)
                /*
                 [Debug] [main] [NetworkManager.swift:27] get(urlString:parameters:) > responseSerializationFailed(Alamofire.AFError.ResponseSerializationFailureReason.jsonSerializationFailed(Error Domain=NSCocoaErrorDomain Code=3840 "Invalid value around character 6." UserInfo={NSDebugDescription=Invalid value around character 6.}))
                 */
            }
        }
    }
}
