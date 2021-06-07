//
//  Chuck_Norris_FactsTests.swift
//  Chuck Norris FactsTests
//
//  Created by Rodrigo Cavalcanti on 05/06/21.
//

import XCTest
@testable import Chuck_Norris_Facts

class Chuck_Norris_FactsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func search() throws {
        let model = ChuckModel()
        model.searchString = "blue"
        model.search()
        XCTAssertEqual(model.searchedFacts.result.count, 18, "there should be 18 facts")
    }
    
}
