//
//  Chuck_Norris_FactsTests.swift
//  Chuck Norris FactsTests
//
//  Created by Rodrigo Cavalcanti on 05/06/21.
//

import XCTest
import Moya
@testable import Chuck_Norris_Facts

class Chuck_Norris_FactsTests: XCTestCase {
    
    func testAPIResponseWithoutStubbing() throws {
        let provider = MoyaProvider<ChuckService>()
        let expectation = self.expectation(description: "Procurar por fatos com a palavra red e encontrar 617 resultados.")
        provider.request(.getCards(keyword: "red")) { res in
            // pass or fail depending on your test needs
            switch res {
            case .success(let response):
                if let decodedResponse = try? JSONDecoder().decode(ChuckModel.AllFacts.self, from: response.data) {
                    if decodedResponse.result.count == 617 {
                        expectation.fulfill()
                    } else {
                        XCTFail("Deveria haver 617 resultados ao invés de \(decodedResponse.total)")
                    }
                }
            case .failure(let error):
                XCTFail("Nenhum dado recebido: \(error.localizedDescription)")
            }
        }
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testAPIResponseStubbing() throws {
        let stubbingProvider = MoyaProvider<ChuckService>(stubClosure: MoyaProvider.immediatelyStub)
        let expectation = self.expectation(description: "Procurar por fatos com a palavra yellow e encontrar 12 resultados.")
        stubbingProvider.request(.getCards(keyword: "yellow")) { res in
            // pass or fail depending on your test needs
            switch res {
            case .success(let response):
                if let decodedResponse = try? JSONDecoder().decode(ChuckModel.AllFacts.self, from: response.data) {
                    if decodedResponse.result.count == 12 {
                        expectation.fulfill()
                    } else {
                        XCTFail("Deveria haver 12 resultados ao invés de \(decodedResponse.total)")
                    }
                }
            case .failure(let error):
                XCTFail("Nenhum dado recebido: \(error.localizedDescription)")
            }
        }
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testIntegrationWithoutStubbing() throws {
        let model = ChuckModel()
        model.searchString = "red"
        let expectation = self.expectation(description: "Procurar por fatos com a palavra red e encontrar 617 resultados.")
        model.search() {
            if $0 == 617 {
                expectation.fulfill()
            } else {
                XCTFail("Deveria haver 617 resultados ao invés de \(model.searchedFacts.total)")
            }
        }
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
    func testIntegrationStubbing() throws {
        let expectation = self.expectation(description: "Procurar por fatos com a palavra yellow e encontrar 12 resultados.")
        let model = ChuckModel(stubbing: true)
        model.searchString = "yellow"
        model.search()
        if model.searchedFacts.total == 12 {
            expectation.fulfill()
        } else {
            XCTFail("searchedFacts: \(model.searchedFacts.total) - \(model.alertTitle): \(model.alertMessage)")
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testIntegrationShortWord() throws {
        let expectation = self.expectation(description: "Procurar por fatos utilizando uma palavra curta e não executar busca")
        let model = ChuckModel(stubbing: true)
        model.searchString = "ye"
        model.search()
        if model.searchedFacts.total == 0 {
            expectation.fulfill()
        } else {
            XCTFail("A busca foi realizada")
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
}
