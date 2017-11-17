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
            }
        }
    }
}


struct NMError: Error {
    enum ErrorKind {
        case transformFailed
    }
    
    let kind: ErrorKind
}

extension Result {
    
    // Note: rethrows 用于参数是一个会抛出异常的闭包的情况，该闭包的异常不会被捕获，会被再次抛出，所以可以直接使用 try，而不用 do－try－catch
    
    /// U 可能为 Optional
    func map<U>(transform: (_: Value) throws -> U) rethrows -> Result<U> {
        switch self {
        case .failure(let error):
            return .failure(error)
        case .success(let value):
            return .success(try transform(value))
        }
    }
    
    /// 若 transform 的返回值为 nil 则作为异常处理
    func flatMap<U>(transform: (_: Value) throws -> U?) rethrows -> Result<U> {
        switch self {
        case .failure(let error):
            return .failure(error)
        case .success(let value):
            guard let transformedValue = try transform(value) else {
                return .failure(NMError(kind: .transformFailed))
            }
            return .success(transformedValue)
        }
    }
    
    
    /// 适用于 transform(value) 之后可能产生 error 的情况
    func flatMap<U>(transform: (_: Value) throws -> Result<U>) rethrows -> Result<U> {
        switch self {
        case .failure(let error):
            return .failure(error)
        case .success(let value):
            return try transform(value)
        }
    }
    
    /// 处理错误，并向下传递
    func mapError(transform: (_: Error) throws -> Error) rethrows -> Result<Value> {
        switch self {
        case .failure(let error):
            return .failure(try transform(error))
        case .success(let value):
            return .success(value)
        }
    }
    
    /// 处理数据（不再向下传递数据，作为数据流的终点）
    func handleValue(handler: (_: Value) -> Void) {
        switch self {
        case .failure(_):
            break
        case .success(let value):
            handler(value)
        }
    }
    
    /// 处理错误（终点）
    func handleError(handler: (_: Error) -> Void) {
        switch self {
        case .failure(let error):
            handler(error)
        case .success(_):
            break
        }
    }
}

extension NetworkManager {
    
    func parseResult(result: Result<Any>) -> Result<Any> {
        return result
            .flatMap { $0 as? [String: Any] }
//            .flatMap(self.checkJSONDict) // 解析错误信息并进行打印，然后继续向下传递，之后业务方可自由选择是否进一步处理错误
//            .flatMap { $0 }
    }

}

protocol Cancellable {
    func cancel()
}

extension Request: Cancellable {}

extension NetworkManager {
    
    @discardableResult
    func getDataWithAPI(url: String,
                          parameters: [String: Any]? = nil
                          ) -> Cancellable? {
        return Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            let s = self.parseResult(result: $0.result)
            console.debug(s)
        }
    }
//    networkCompletionHandler: ()->Result
}
