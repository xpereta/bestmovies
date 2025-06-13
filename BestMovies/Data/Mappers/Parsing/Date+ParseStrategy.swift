import Foundation

extension Date.ParseStrategy {
    static let shortISO8601 = Date.ParseStrategy(
        format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
        timeZone: .gmt,
        isLenient: false,
    )
}
