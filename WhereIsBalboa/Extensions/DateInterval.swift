import Foundation

extension DateInterval {
    private static var delimiterString = " * "
    private static var formatter = DateFormatter.fullDate
    
    init?(_ string: String, timeZone: TimeZone = .current) {
        let components = string.components(separatedBy: DateInterval.delimiterString)
        guard
            components.count == 2,
            let start = DateInterval.formatter.date(from: components[0]),
            let end = DateInterval.formatter.date(from: components[1])
        else {
            return nil
        }
        self.init(start: start.startOfDay(in: timeZone), end: end.endOfDay(in: timeZone))
    }
    
    var stringRepresentation: String {
        return DateInterval.formatter.string(from: start) + DateInterval.delimiterString + DateInterval.formatter.string(from: end)
    }
}
