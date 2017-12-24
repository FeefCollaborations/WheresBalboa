import Foundation

fileprivate struct Constants {
    static let dayInterval: TimeInterval = 60 * 60 * 24
}

extension Date {
    func daysSince(_ date: Date = Date()) -> Int {        
        return Int(self.timeIntervalSince1970 / Constants.dayInterval) - Int(date.timeIntervalSince1970 / Constants.dayInterval)
    }
    
    func date(daysLater days: Int) -> Date {
        return self + Constants.dayInterval * TimeInterval(days)
    }
}
