import Foundation

fileprivate struct Constants {
    static let dayInterval: TimeInterval = 60 * 60 * 24
}

extension Date {
    func daysSince(_ date: Date = Date(), using calendar: Calendar = .current) -> Int {
        guard let daysSince = calendar.dateComponents(Set([.day]), from: date.startOfDay(), to: self.startOfDay()).day else {
            // TODO: Log error
            fatalError()
        }
        return daysSince
    }
    
    func date(daysLater days: Int, using calendar: Calendar = .current) -> Date {
        guard let date = calendar.date(byAdding: .day, value: days, to: self) else {
            // TODO: Log error
            fatalError()
        }
        return date
    }
    
    func startOfDay(using calendar: Calendar = .current) -> Date {
        return calendar.startOfDay(for: self)
    }
    
    func endOfDay(using calendar: Calendar = .current) -> Date {
        return startOfDay(using: calendar).date(daysLater: 1, using: calendar)
    }
    
    var isDistantFuture: Bool {
        return daysSince(Date.distantFuture) == 0
    }
    
    var isDistantPast: Bool {
        return daysSince(Date.distantPast) == 0
    }
}
