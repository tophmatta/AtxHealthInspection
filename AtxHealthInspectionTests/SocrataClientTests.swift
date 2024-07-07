//
//  SocrataClientTests.swift
//  AtxHealthInspectionTests
//
//  Created by Toph Matta on 7/7/24.
//

import XCTest
@testable import AtxHealthInspection

final class SocrataClientTests: XCTestCase {

    var client: ISocrataClient!
    
    override func setUp() {
        super.setUp()
        client = SocrataClient()
    }
    
    override func tearDown() {
        client = nil
        super.tearDown()
    }
    
    func testGetWithValidInput() async throws {
        let result = await client.get("The 04 Lounge")
        switch result {
        case .success(let report):
            XCTAssertNotNil(report)
        case .failure(let error):
            XCTFail("Expected success, but got failure with error: \(error)")
        }
    }
    
    func testGetWithEmptyInput() async {
        let result = await client.get("")
        switch result {
        case .success:
            XCTFail("Expected failure for empty input, but got success")
        case .failure(let error):
            XCTAssertEqual(error, .emptyValue)
        }
    }
    
    func testPrepareForRequestWithPrefixToTrim() {
        let input = "The Vincent's Restaurant"
        let expected = "vincent restaurant"
        let result = client.prepareForRequest(input)
        XCTAssertEqual(result, expected)
    }
    
    func testPrepareForRequestOneWord() {
        let input = "Amy's "
        let expected = "amy"
        let result = client.prepareForRequest(input)
        XCTAssertEqual(result, expected)
    }
    
    func testPrepareForAnotherApostrophe() {
        let input = "Fat Daddy's Chicken "
        let expected = "fat daddy chicken"
        let result = client.prepareForRequest(input)
        XCTAssertEqual(result, expected)
    }

    
    func testPrepareAllCaps() {
        let input = "ATX Cocina"
        let expected = "atx cocina"
        let result = client.prepareForRequest(input)
        XCTAssertEqual(result, expected)

    }
}