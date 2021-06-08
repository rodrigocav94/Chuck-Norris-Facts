//
//  Chuck_Norris_FactsUITests.swift
//  Chuck Norris FactsUITests
//
//  Created by Rodrigo Cavalcanti on 05/06/21.
//

import XCTest

extension XCUIApplication {
   func filterCells(containing labels: String...) -> XCUIElementQuery {
        var cells = self.cells

        for label in labels {
            cells = cells.containing(NSPredicate(format: "label CONTAINS %@", label))
        }
        return cells
    }
}

class Chuck_Norris_FactsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSuccessfulSearching() throws {
        let app = XCUIApplication()
        let searchField = app.searchFields.element
        let table = app.tables.cells
        
        app.launch()
        searchField.tap()
        searchField.typeText("blue\n")
        XCTAssertEqual(table.element(boundBy: 17).waitForExistence(timeout: 5), true, "O 18º resultado não existe")
        XCTAssertEqual(table.count, 18, "Deveria haver 18 resultados para a busca")
    }
    
    func testShareSheet() throws {
        let app = XCUIApplication()
        let searchField = app.searchFields.element
        let table = app.tables.cells
        let messageButton = app.collectionViews.cells["Messages"].children(matching: .other).element
        
        app.launch()
        searchField.tap()
        searchField.typeText("red\n")
        XCTAssertEqual(table.element(boundBy: 0).waitForExistence(timeout: 5), true, "A busca não obteve sucesso")
        table.element(boundBy: 0).images["Share"].tap()
        XCTAssertEqual(messageButton.exists, true, "A share sheet deveria estar presente")
    }
    
    func testUnsuccessfulSearching() throws {
        let app = XCUIApplication()
        let searchField = app.searchFields.element
        let aleartToast = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        
        app.launch()
        searchField.tap()
        searchField.typeText("rodrigo\n")
        XCTAssertEqual(aleartToast.waitForExistence(timeout: 5), true, "Deveria haver um Alert Toast")
    }
    
    func testLikingAndDislikingAFact() throws {
        let app = XCUIApplication()
        let searchField = app.searchFields.element
        let cancelButton = app.navigationBars["Chuck Norris Facts"].buttons["Cancel"]
        let blackEyedPeasFact = app.filterCells(containing: "Black Eyed Peas")
        
        app.launch()
        if blackEyedPeasFact.count > 0 {
            for fact in 0..<blackEyedPeasFact.count {
                while !blackEyedPeasFact.element(boundBy: fact).isHittable {
                    app.swipeUp(velocity: 1000)
                }
                blackEyedPeasFact.element(boundBy: fact).images.element(boundBy: 0).tap()
                while !searchField.isHittable {
                    app.swipeDown(velocity: 5000)
                }
            }
        }
        XCTAssertEqual(blackEyedPeasFact.count, 0, "Nenhum fato de Black Eyed Peas deveria estar mais na lista de favoritos")
        searchField.tap()
        searchField.typeText("black eyed peas\n")
        XCTAssertEqual(blackEyedPeasFact.element.waitForExistence(timeout: 10), true, "Deveria haver pelo menos um fato de The black eyed peas")
        blackEyedPeasFact.element(boundBy: 0).images.element(boundBy: 0).tap()
        cancelButton.tap()
        XCTAssertEqual(blackEyedPeasFact.count, 1, "O fato deveria estar na lista de favoritos")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
