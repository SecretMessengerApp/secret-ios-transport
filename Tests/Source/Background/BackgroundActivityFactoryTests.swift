//
//

import UIKit
import XCTest
import WireTesting
@testable import WireTransport

class BackgroundActivityFactoryTests: XCTestCase {

    var factory: BackgroundActivityFactory!
    var activityManager: MockBackgroundActivityManager!

    override func setUp() {
        super.setUp()
        activityManager = MockBackgroundActivityManager()
        factory = BackgroundActivityFactory.shared
        factory.activityManager = activityManager
        factory.mainQueue = .global()
    }

    override func tearDown() {
        activityManager.reset()
        factory.reset()
        activityManager = nil
        factory = nil
        super.tearDown()
    }

    func testThatItCreatesActivity() {
        // WHEN
        let activity = factory.startBackgroundActivity(withName: "Activity 1")

        // THEN
        XCTAssertNotNil(activity)
        XCTAssertEqual(activity?.name, "Activity 1")
        XCTAssertTrue(factory.isActive)
        XCTAssertEqual(activityManager.numberOfTasks, 1)
    }

    func testThatItCreatesOnlyOneSystemTaskWithMultipleActivities() {
        // WHEN
        _ = factory.startBackgroundActivity(withName: "Activity 1")
        _ = factory.startBackgroundActivity(withName: "Activity 2")

        // THEN
        XCTAssertTrue(factory.isActive)
        XCTAssertEqual(activityManager.numberOfTasks, 1)
        XCTAssertEqual(factory.activities.count, 2)
    }

    func testThatItDoesNotCreateActivityIfTheAppIsBeingSuspended() {
        // GIVEN
        activityManager.triggerExpiration()

        // WHEN
        let activity = factory.startBackgroundActivity(withName: "Activity 1")

        // THEN
        XCTAssertNil(activity)
        XCTAssertNil(factory.currentBackgroundTask)
    }

    func testThatItRemovesTaskWhenItEnds() {
        // GIVEN
        let activity = factory.startBackgroundActivity(withName: "Activity 1")!

        // WHEN
        factory.endBackgroundActivity(activity)

        // THEN
        XCTAssertFalse(factory.isActive)
        XCTAssertTrue(factory.activities.isEmpty)
        XCTAssertEqual(activityManager.numberOfTasks, 0)
    }

    func testThatItDoesNotRemoveTaskWhenItEndsIfThereAreMoreTasks() {
        // GIVEN
        let activity1 = factory.startBackgroundActivity(withName: "Activity 1")!
        let activity2 = factory.startBackgroundActivity(withName: "Activity 2")!

        // WHEN
        factory.endBackgroundActivity(activity1)

        // THEN
        XCTAssertTrue(factory.isActive)
        XCTAssertEqual(factory.activities, [activity2])
        XCTAssertEqual(activityManager.numberOfTasks, 1)
    }

    func testThatItCallsExpirationHandlerOnCreatedActivities() {
        // GIVEN
        let expirationExpectation = expectation(description: "The expiration handler is called.")

        let activity = factory.startBackgroundActivity(withName: "Activity 1") {
            expirationExpectation.fulfill()
        }

        // WHEN
        XCTAssertNotNil(activity)
        activityManager.triggerExpiration()

        // THEN
        waitForExpectations(timeout: 0.5, handler: nil)
        XCTAssertFalse(factory.isActive)
        XCTAssertTrue(factory.activities.isEmpty)
        XCTAssertEqual(activityManager.numberOfTasks, 0)
    }    
}

// MARK: - Helpers

extension BackgroundActivityFactory {

    @objc func reset() {
        currentBackgroundTask = nil
        activities.removeAll()
        activityManager = nil
        mainQueue = .main
    }

}
