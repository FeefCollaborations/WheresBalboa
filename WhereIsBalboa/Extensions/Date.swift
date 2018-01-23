import Foundation

fileprivate struct Constants {
    static let dayInterval: TimeInterval = 60 * 60 * 24
}

extension Date {
    func daysSince(_ date: Date = Date(), in timeZone: TimeZone = .current) -> Int {
        return Int(startOfDay(in: timeZone).timeIntervalSince1970 - date.startOfDay(in: timeZone).timeIntervalSince1970) / Int(Constants.dayInterval)
    }
    
    func date(daysLater days: Int) -> Date {
        return self + Constants.dayInterval * TimeInterval(days)
    }
    
    func startOfDay(in timeZone: TimeZone = .current) -> Date {
        let seconds = TimeInterval(timeZone.secondsFromGMT())
        let timeIntoDay = (timeIntervalSince1970 + seconds).truncatingRemainder(dividingBy: Constants.dayInterval)
        return self - timeIntoDay
    }
    
    func endOfDay(in timeZone: TimeZone = .current) -> Date {
        return startOfDay(in: timeZone).date(daysLater: 1)
    }
}
