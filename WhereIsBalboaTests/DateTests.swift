import XCTest
@testable import WhereIsBalboa

class DateTests: XCTestCase {
    static let oneHour = 60 * 60
    static let oneDay = oneHour * 24
    let oneHour: Int = DateTests.oneHour
    let oneDay: Int = DateTests.oneDay
    let threeDaysFourHours = Date(timeIntervalSince1970: TimeInterval(oneDay * 3 + oneHour * 4))
    let fourDaysFiveHours = Date(timeIntervalSince1970: TimeInterval(oneDay * 4 + oneHour * 5))
    
    func calendar(with timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    func testDaysSince() {
        let daysInSameTimeZone = fourDaysFiveHours.daysSince(threeDaysFourHours, using: calendar(with: TimeZone(secondsFromGMT: oneHour * 3)!))
        XCTAssertEqual(daysInSameTimeZone, 1)
        let daysInTooForwardTimeZone = fourDaysFiveHours.daysSince(threeDaysFourHours, using: calendar(with: TimeZone(secondsFromGMT: -oneHour * 4)!))
        XCTAssertEqual(daysInTooForwardTimeZone, 1)
        let negativeDaysInSameTimeZone = threeDaysFourHours.daysSince(fourDaysFiveHours, using: calendar(with: TimeZone(secondsFromGMT: oneHour * 3)!))
        XCTAssertEqual(negativeDaysInSameTimeZone, -1)
    }
    
    func testDaysLater() {
        let oneDayLater = fourDaysFiveHours.date(daysLater: 1)
        XCTAssertEqual(oneDayLater, fourDaysFiveHours + TimeInterval(oneDay))
        let twelveDaysLater = fourDaysFiveHours.date(daysLater: 12)
        XCTAssertEqual(twelveDaysLater, fourDaysFiveHours + TimeInterval(oneDay * 12))
    }
    
    func testStartOfDay() {
        let startOfThreeDaysGMT = threeDaysFourHours.startOfDay(using: calendar(with: TimeZone(secondsFromGMT: 0)!))
        XCTAssertEqual(startOfThreeDaysGMT, Date(timeIntervalSince1970: TimeInterval(oneDay * 3)))
        let startOfThreeDaysOneHourOffset = threeDaysFourHours.startOfDay(using: calendar(with: TimeZone(secondsFromGMT: -oneHour)!))
        XCTAssertEqual(startOfThreeDaysOneHourOffset, Date(timeIntervalSince1970: TimeInterval(oneDay * 3 + oneHour)))
    }
    
    func testEndOfDay() {
        let startOfDay = threeDaysFourHours.startOfDay(using: calendar(with: TimeZone(secondsFromGMT: 0)!))
        let endOfDay = threeDaysFourHours.endOfDay(using: calendar(with: TimeZone(secondsFromGMT: 0)!))
        XCTAssertEqual(endOfDay, startOfDay + TimeInterval(oneDay))
        
        let startOfDay2 = threeDaysFourHours.startOfDay(using: calendar(with: TimeZone(secondsFromGMT: -oneHour * 5)!))
        let endOfDay2 = threeDaysFourHours.endOfDay(using: calendar(with: TimeZone(secondsFromGMT: -oneHour * 5)!))
        XCTAssertEqual(endOfDay2, startOfDay2 + TimeInterval(oneDay))
    }
}
