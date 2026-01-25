import XCTest

final class TodoAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testApplicationFlow() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.exists)
        
        let navTitle = app.staticTexts["Lista Zadań"]
        XCTAssertTrue(navTitle.exists)
        XCTAssertTrue(navTitle.isHittable)

        let textField = app.textFields["Dodaj nowe zadanie..."]
        XCTAssertTrue(textField.exists)
        XCTAssertEqual(textField.value as? String, "Dodaj nowe zadanie...")
        
        let addButton = app.buttons["plus.circle.fill"]
        XCTAssertTrue(addButton.exists)
        XCTAssertFalse(addButton.isEnabled)
        
        let editButton = app.buttons["Edit"]
        XCTAssertTrue(editButton.exists)
        XCTAssertTrue(editButton.isEnabled)

        let collectionViews = app.collectionViews
        XCTAssertTrue(collectionViews.element.exists)
        
        XCTAssertTrue(collectionViews.staticTexts["Zrobić zakupy spożywcze"].exists)
        XCTAssertTrue(collectionViews.staticTexts["Wyprowadzić psa"].exists)
        XCTAssertTrue(collectionViews.staticTexts["Opłacić rachunki"].exists)
        XCTAssertTrue(collectionViews.staticTexts["Umówić wizytę u lekarza"].exists)

        let initialCount = collectionViews.cells.count
        XCTAssertGreaterThanOrEqual(initialCount, 4)

        textField.tap()
        textField.typeText("Testowe Zadanie 1")
        
        XCTAssertEqual(textField.value as? String, "Testowe Zadanie 1")
        XCTAssertTrue(addButton.isEnabled)
        
        addButton.tap()
        
        XCTAssertTrue(collectionViews.staticTexts["Testowe Zadanie 1"].exists)
        XCTAssertEqual(collectionViews.cells.count, initialCount + 1)
        
        XCTAssertEqual(textField.value as? String, "Dodaj nowe zadanie...")
        XCTAssertFalse(addButton.isEnabled)

        textField.tap()
        textField.typeText("Do usunięcia")
        addButton.tap()
        
        XCTAssertTrue(collectionViews.staticTexts["Do usunięcia"].exists)
        let countAfterSecondAdd = collectionViews.cells.count
        XCTAssertEqual(countAfterSecondAdd, initialCount + 2)

        let itemToDelete = collectionViews.staticTexts["Do usunięcia"]
        itemToDelete.swipeLeft()
        
        let deleteButton = collectionViews.buttons["Delete"]
        XCTAssertTrue(deleteButton.exists)
        deleteButton.tap()
        
        XCTAssertFalse(collectionViews.staticTexts["Do usunięcia"].exists)
        XCTAssertEqual(collectionViews.cells.count, countAfterSecondAdd - 1)

        editButton.tap()
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
        XCTAssertFalse(app.buttons["Edit"].exists)
        
        doneButton.tap()
        XCTAssertTrue(app.buttons["Edit"].exists)
        XCTAssertFalse(app.buttons["Done"].exists)

        textField.tap()
        textField.typeText("A")
        textField.typeText("B")
        XCTAssertTrue(addButton.isEnabled)
        
        let deleteKey = String(XCUIKeyboardKey.delete.rawValue)
        textField.typeText(deleteKey)
        textField.typeText(deleteKey)
        
        XCTAssertFalse(addButton.isEnabled)
    }
}
