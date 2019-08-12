import Foundation

extension Date {

    public static func from(
        day: Int,
        month: Int,
        year: Int,
        calendar: Calendar = .current) -> Date? {

        let dateComponents = DateComponents(
            calendar: calendar,
            timeZone: nil,
            era: nil,
            year: year,
            month: month,
            day: day,
            hour: nil,
            minute: nil,
            second: nil,
            nanosecond: nil,
            weekday: nil,
            weekdayOrdinal: nil,
            quarter: nil,
            weekOfMonth: nil,
            weekOfYear: nil,
            yearForWeekOfYear: nil)
        return calendar.date(from: dateComponents)
    }
}
