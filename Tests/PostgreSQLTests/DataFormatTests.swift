@testable import PostgreSQL
import XCTest

final class DataFormatTests: BaseTests {
    func testCases() {
        // Assert
        XCTAssertEqual(DataFormat.allCases.count, 2)
        XCTAssertEqual(DataFormat.binary.rawValue, 1)
        XCTAssertEqual(DataFormat.binary.description, "binary")
        XCTAssertEqual(DataFormat.text.rawValue, 0)
        XCTAssertEqual(DataFormat.text.description, "text")
    }
}
