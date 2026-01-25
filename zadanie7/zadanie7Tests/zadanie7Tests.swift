import XCTest
@testable import zadanie7

final class TodoAppTests: XCTestCase {

    var viewModel: TodoViewModel!

    override func setUp() {
        super.setUp()
        viewModel = TodoViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.tasks.count, 4)
        XCTAssertEqual(viewModel.newTaskTitle, "")
        XCTAssertFalse(viewModel.tasks.isEmpty)
        XCTAssertEqual(viewModel.tasks.first?.title, "Zrobić zakupy spożywcze")
        XCTAssertEqual(viewModel.tasks.last?.title, "Umówić wizytę u lekarza")
    }

    func testTodoItemStructure() {
        let item1 = TodoItem(title: "Test A")
        let item2 = TodoItem(title: "Test A")
        
        XCTAssertEqual(item1.title, "Test A")
        XCTAssertNotEqual(item1.id, item2.id)
        XCTAssertNotEqual(item1, item2)
        XCTAssertNotNil(item1.id)
    }

    func testAddingTask() {
        viewModel.newTaskTitle = "Nowe Zadanie"
        viewModel.addTask()
        
        XCTAssertEqual(viewModel.tasks.count, 5)
        XCTAssertEqual(viewModel.tasks.last?.title, "Nowe Zadanie")
        XCTAssertEqual(viewModel.newTaskTitle, "")
        XCTAssertTrue(viewModel.tasks.contains { $0.title == "Nowe Zadanie" })
    }

    func testAddingEmptyTask() {
        let initialCount = viewModel.tasks.count
        viewModel.newTaskTitle = ""
        viewModel.addTask()
        
        XCTAssertEqual(viewModel.tasks.count, initialCount)
        XCTAssertEqual(viewModel.tasks.count, 4)
    }

    func testDeletingTask() {
        let firstTaskTitle = viewModel.tasks[0].title
        let secondTaskTitle = viewModel.tasks[1].title
        
        viewModel.deleteTasks(at: IndexSet(integer: 0))
        
        XCTAssertEqual(viewModel.tasks.count, 3)
        XCTAssertNotEqual(viewModel.tasks.first?.title, firstTaskTitle)
        XCTAssertEqual(viewModel.tasks.first?.title, secondTaskTitle)
    }

    func testDeleteLastTask() {
        let lastIndex = viewModel.tasks.count - 1
        viewModel.deleteTasks(at: IndexSet(integer: lastIndex))
        
        XCTAssertEqual(viewModel.tasks.count, 3)
        XCTAssertNotEqual(viewModel.tasks.last?.title, "Umówić wizytę u lekarza")
    }

    func testMultipleOperations() {
        viewModel.deleteTasks(at: IndexSet(integer: 0))
        XCTAssertEqual(viewModel.tasks.count, 3)
        
        viewModel.newTaskTitle = "Zadanie X"
        viewModel.addTask()
        XCTAssertEqual(viewModel.tasks.count, 4)
        XCTAssertEqual(viewModel.tasks.last?.title, "Zadanie X")
        
        viewModel.deleteTasks(at: IndexSet(integer: 3))
        XCTAssertEqual(viewModel.tasks.count, 3)
        XCTAssertFalse(viewModel.tasks.contains { $0.title == "Zadanie X" })
    }
}
