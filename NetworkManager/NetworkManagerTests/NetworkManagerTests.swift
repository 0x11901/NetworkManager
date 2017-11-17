//
//  NetworkManagerTests.swift
//  NetworkManagerTests
//
//  Created by 王靖凯 on 2017/11/16.
//  Copyright © 2017年 王靖凯. All rights reserved.
//

import XCTest
@testable import NetworkManager

class NetworkManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testgetDataWithURL_invalidURL_failureResult() {
        let expectation = XCTestExpectation(description: "测试无效URL")
        let timeout = 15 as TimeInterval
        NetworkManager
            .shared
            .getDataWithURL(url: "https://raw.githubusercontent.com/0x11901/super-train/master/test.jsonsss") {
                expectation.fulfill()
                XCTAssertTrue($0.isFailure)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
}
