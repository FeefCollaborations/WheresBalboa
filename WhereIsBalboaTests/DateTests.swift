import XCTest
@testable import WhereIsBalboa

class DateTests: XCTestCase {
    static let oneHour = 60 * 60
    static let oneDay = oneHour * 24
    let oneHour: Int = DateTests.oneHour
    let oneDay: Int = DateTests.oneDay
    let threeDaysFourHours = Date(timeIntervalSince1970: TimeInterval(oneDay * 3 + oneHour * 4))
    let fourDaysThreeHours = Date(timeIntervalSince1970: TimeInterval(oneDay * 4 + oneHour * 3))

    func testDaysSince() {
        let daysInSameTimeZone = fourDaysThreeHours.daysSince(threeDaysFourHours, in: TimeZone(secondsFromGMT: oneHour * 3)!)
        XCTAssertEqual(daysInSameTimeZone, 1)
        let daysInTooForwardTimeZone = fourDaysThreeHours.daysSince(threeDaysFourHours, in: TimeZone(secondsFromGMT: -oneHour * 4)!)
        XCTAssertEqual(daysInTooForwardTimeZone, 0)
        let negativeDaysInSameTimeZone = threeDaysFourHours.daysSince(fourDaysThreeHours, in: TimeZone(secondsFromGMT: oneHour * 3)!)
        XCTAssertEqual(negativeDaysInSameTimeZone, -1)
    }
    
    func testDaysLater() {
        let oneDayLater = fourDaysThreeHours.date(daysLater: 1)
        XCTAssertEqual(oneDayLater, fourDaysThreeHours + TimeInterval(oneDay))
        let twelveDaysLater = fourDaysThreeHours.date(daysLater: 12)
        XCTAssertEqual(twelveDaysLater, fourDaysThreeHours + TimeInterval(oneDay * 12))
    }
    
    func testStartOfDay() {
        let startOfThreeDaysGMT = threeDaysFourHours.startOfDay(in: TimeZone(secondsFromGMT: 0)!)
        XCTAssertEqual(startOfThreeDaysGMT, Date(timeIntervalSince1970: TimeInterval(oneDay * 3)))
        let startOfThreeDaysOneHourOffset = threeDaysFourHours.startOfDay(in: TimeZone(secondsFromGMT: -oneHour)!)
        XCTAssertEqual(startOfThreeDaysOneHourOffset, Date(timeIntervalSince1970: TimeInterval(oneDay * 3 + oneHour)))
    }
}
