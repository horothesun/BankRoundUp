import Quick
import Nimble
import BankRoundUp

final class Date_StartOfWeekSpec: QuickSpec {

    override func spec() {

        describe("Date") {

            describe("startOfWeek") {
                var date: Date!
                var calendar: Calendar!
                beforeEach {
                    calendar = Calendar(identifier: .gregorian)
                }

                context("Thu 18 Jan 2018") {
                    beforeEach {
                        date = .from(
                            day: 18,
                            month: 1,
                            year: 2018,
                            calendar: calendar)
                    }

                    it("must return Sun 14 Jan 2018") {
                        let result = date.startOfWeek(calendar: calendar)!
                        let resultComponents = calendar.dateComponents(
                            Set(arrayLiteral: .day, .month, .year),
                            from: result)
                        expect(resultComponents.day!).to(equal(14))
                        expect(resultComponents.month!).to(equal(1))
                        expect(resultComponents.year!).to(equal(2018))
                    }

                    context("given a second date Tue 16 Jan 2018") {
                        var secondDate: Date!
                        beforeEach {
                            secondDate = .from(
                                day: 16,
                                month: 1,
                                year: 2018,
                                calendar: calendar)
                        }

                        it("must return same startOfWeek of second date") {
                            expect(date.startOfWeek(calendar: calendar)!)
                                .to(equal(secondDate.startOfWeek(calendar: calendar)!))
                        }
                    }
                }
            }
        }
    }
}
