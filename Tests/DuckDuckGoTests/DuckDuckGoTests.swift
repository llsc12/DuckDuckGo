import XCTest
@testable import DuckDuckGo

final class DuckDuckGoTests: XCTestCase {
    func testExample() async throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let search = try await DuckDuckGo.search("egg")
        print(search.results.first!)
    }
}
