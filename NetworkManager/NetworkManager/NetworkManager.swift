//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by 王靖凯 on 2017/11/16.
//  Copyright © 2017年 王靖凯. All rights reserved.
//

import Alamofire
import Foundation

class NetworkManager {
    private init() {}

    static let shared = { () -> NetworkManager in
        let instance = NetworkManager()
        return instance
    }()
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
        case let .failure(error):
            return .failure(error)
        case let .success(value):
            return .success(try transform(value))
        }
    }

    /// 若 transform 的返回值为 nil 则作为异常处理
    func flatMap<U>(transform: (_: Value) throws -> U?) rethrows -> Result<U> {
        switch self {
        case let .failure(error):
            return .failure(error)
        case let .success(value):
            guard let transformedValue = try transform(value) else {
                return .failure(NMError(kind: .transformFailed))
            }
            return .success(transformedValue)
        }
    }

    /// 适用于 transform(value) 之后可能产生 error 的情况
    func flatMap<U>(transform: (_: Value) throws -> Result<U>) rethrows -> Result<U> {
        switch self {
        case let .failure(error):
            return .failure(error)
        case let .success(value):
            return try transform(value)
        }
    }

    /// 处理错误，并向下传递
    func mapError(transform: (_: Error) throws -> Error) rethrows -> Result<Value> {
        switch self {
        case let .failure(error):
            return .failure(try transform(error))
        case let .success(value):
            return .success(value)
        }
    }

    /// 处理数据（不再向下传递数据，作为数据流的终点）
    func handleValue(handler: (_: Value) -> Void) {
        switch self {
        case .failure:
            break
        case let .success(value):
            handler(value)
        }
    }

    /// 处理错误（终点）
    func handleError(handler: (_: Error) -> Void) {
        switch self {
        case let .failure(error):
            handler(error)
        case .success:
            break
        }
    }
}

extension NetworkManager {
    func parseResult(result: Result<Any>) -> Result<Any> {
        return result
            .flatMap { $0 as? [String: Any] } // 如有需要可做进一步处理
    }
}

/// 显式地声明Request遵守Cancellable协议
protocol Cancellable {
    func cancel()
}

// MARK: - Request本来就实现了cancel方法

extension Request: Cancellable {}

extension NetworkManager {
    @discardableResult
    func get(url: String,
             parameters: [String: Any]? = nil,
             networkCompletionHandler: @escaping (Result<Any>) -> Void
    ) -> Cancellable? {
        return Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            networkCompletionHandler(self.parseResult(result: $0.result))
        }
    }

    @discardableResult
    func post(url: String,
              parameters: [String: Any]? = nil,
              networkCompletionHandler: @escaping (Result<Any>) -> Void
    ) -> Cancellable? {
        return Alamofire.request(url, method: .post, parameters: parameters).responseJSON {
            networkCompletionHandler(self.parseResult(result: $0.result))
        }
    }
}
