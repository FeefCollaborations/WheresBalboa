import Foundation

extension DateInterval {
    private static var distantPastString = "distantPast"
    private static var distantFutureString = "distantFuture"
    static var delimiterString = " * "
    private static var formatter = DateFormatter.fullDate
    
    init?(_ string: String, calendar: Calendar = .current) {
        let components = string.components(separatedBy: DateInterval.delimiterString)
        guard
            components.count == 2,
            let start = DateInterval.date(from: components[0]),
            let end = DateInterval.date(from: components[1])
        else {
            return nil
        }

        self.init(start: start.startOfDay(using: calendar), end: end.startOfDay(using: calendar) + 1)
    }
    
    private static func date(from string: String) -> Date? {
        if let date = DateInterval.formatter.date(from: string) {
            return date
        } else if string == distantPastString {
            return Date.distantPast
        } else if string == distantFutureString {
            return Date.distantFuture
        } else {
            return nil
        }
    }
    
    var stringRepresentation: String {
        let startText = start.isDistantPast ? DateInterval.distantPastString : DateInterval.formatter.string(from: start)
        let endText = start.isDistantFuture ? DateInterval.distantFutureString : DateInterval.formatter.string(from: end)
        return startText + DateInterval.delimiterString + endText
    }
}
