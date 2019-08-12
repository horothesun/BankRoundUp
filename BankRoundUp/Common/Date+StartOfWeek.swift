import Foundation

extension Date {

    public func startOfWeek(calendar: Calendar = .current) -> Date? {
        let dateComponents = calendar
            .dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: dateComponents)
    }
}
