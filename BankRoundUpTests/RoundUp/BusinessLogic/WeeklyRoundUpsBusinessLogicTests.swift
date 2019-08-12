import Quick
import Nimble
import RxSwift
import RxTest
@testable import BankRoundUp

final class WeeklyRoundUpsBusinessLogicSpec: QuickSpec {

    private let calendar = Calendar(identifier: .gregorian)

    private lazy var transaction1: Transaction = {
        return .init(
            id: UUID(),
            currency: "GBP",
            amount: -10.97,
            direction: .outbound,
            created: Date.from(day: 29, month: 6, year: 2018,
                               calendar: calendar)!,
            narrative: "",
            source: .DIRECT_DEBIT,
            balance: 2000)
    }()

    private lazy var transaction2: Transaction = {
        return .init(
            id: UUID(),
            currency: "GBP",
            amount: -3.89,
            direction: .outbound,
            created: Date.from(day: 27, month: 6, year: 2018,
                               calendar: calendar)!,
            narrative: "",
            source: .DIRECT_DEBIT,
            balance: 2000)
    }()

    private lazy var firstWeekTransactions: [Transaction] = {
        return [transaction1, transaction2]
    }()

    private lazy var firstWeekStartDate: Date = {
        return Date.from(day: 24, month: 6, year: 2018, calendar: self.calendar)!
    }()

    private let firstWeekRoundUp = (11 - 10.97) + (4 - 3.89)

    private lazy var transaction3: Transaction = {
        return .init(
            id: UUID(),
            currency: "GBP",
            amount: -9.99,
            direction: .outbound,
            created: Date.from(day: 23, month: 6, year: 2018,
                               calendar: calendar)!,
            narrative: "",
            source: .DIRECT_DEBIT,
            balance: 2000)
    }()

    private lazy var transaction4: Transaction = {
        return .init(
            id: UUID(),
            currency: "GBP",
            amount: -12.92,
            direction: .outbound,
            created: Date.from(day: 20, month: 6, year: 2018,
                               calendar: calendar)!,
            narrative: "",
            source: .DIRECT_DEBIT,
            balance: 2000)
    }()

    private lazy var secondWeekTransactions: [Transaction] = {
        return [transaction3, transaction4]
    }()

    private lazy var secondWeekStartDate: Date = {
        return Date.from(day: 17, month: 6, year: 2018, calendar: self.calendar)!
    }()

    private let secondWeekRoundUp = (10 - 9.99) + (13 - 12.92)

    private lazy var transaction5: Transaction = {
        return .init(
            id: UUID(),
            currency: "GBP",
            amount: -101.12,
            direction: .outbound,
            created: Date.from(day: 12, month: 6, year: 2018,
                               calendar: calendar)!,
            narrative: "",
            source: .DIRECT_DEBIT,
            balance: 2000)
    }()

    // this inbound transaction must be ignored by weeklyRoundUps()
    private lazy var transaction6: Transaction = {
        return .init(
            id: UUID(),
            currency: "GBP",
            amount: -1.01,
            direction: .inbound,
            created: Date.from(day: 12, month: 6, year: 2018,
                               calendar: calendar)!,
            narrative: "",
            source: .DIRECT_DEBIT,
            balance: 2000)
    }()

    private lazy var thirdWeekTransactions: [Transaction] = {
        return [transaction5, transaction6]
    }()

    private lazy var thirdWeekStartDate: Date = {
        return Date.from(day: 10, month: 6, year: 2018, calendar: self.calendar)!
    }()

    private let thirdWeekRoundUp = (102 - 101.12)

    private lazy var allTransactions: [Transaction] = {
        return firstWeekTransactions
            + secondWeekTransactions
            + thirdWeekTransactions
    }()

    override func spec() {

        describe("WeeklyRoundUpsBusinessLogic") {
            var businessLogic: WeeklyRoundUpsBusinessLogic!
            var transactionsFetchingStub: TransactionsFetchingGatewayProtocol!
            var scheduler: TestScheduler!
            var disposeBag: DisposeBag!

            beforeEach {
                disposeBag = DisposeBag()
            }

            describe("weeklyRoundUps()") {
                var observer: TestableObserver<[WeeklyRoundUp]>!

                beforeEach {
                    scheduler = TestScheduler(initialClock: 0)
                    observer = scheduler.createObserver([WeeklyRoundUp].self)
                }

                context("failing transactionsFetchingBusinessLogic") {
                    beforeEach {
                        transactionsFetchingStub =
                            FailingTransactionsFetchingGatewayStub()
                        businessLogic = WeeklyRoundUpsBusinessLogic(
                            gateway: transactionsFetchingStub,
                            calendar: self.calendar)
                        businessLogic.weeklyRoundUps()
                            .subscribe(observer)
                            .disposed(by: disposeBag)
                        scheduler.start()
                    }
                    it("must fail") {
                        expect(observer.events).to(haveCount(1))
                        expect(observer.events.first!.value).to(beErrorEvent())
                    }
                }

                context("succeding transactionsFetchingBusinessLogic") {
                    beforeEach {
                        transactionsFetchingStub =
                            SucceedingTransactionsFetchingGatewayStub(
                                transactions: self.allTransactions)
                        businessLogic = WeeklyRoundUpsBusinessLogic(
                            gateway: transactionsFetchingStub,
                            calendar: self.calendar)
                        businessLogic.weeklyRoundUps()
                            .subscribe(observer)
                            .disposed(by: disposeBag)
                        scheduler.start()
                    }
                    it("must produce [.next([weeklyRoundUp1, weeklyRoundUp2, weeklyRoundUp3]), .completed]") {
                        expect(observer.events).to(haveCount(2))
                        expect(observer.events.first!.value)
                            .to(beNextEvent(satisfying: { weeklyRoundUps -> Bool in
                                guard weeklyRoundUps.count == 3 else { return false }
                                let areRoundUpsOk =
                                    weeklyRoundUps[0].amount == self.firstWeekRoundUp
                                        && weeklyRoundUps[1].amount == self.secondWeekRoundUp
                                        && weeklyRoundUps[2].amount == self.thirdWeekRoundUp
                                let areStartOfWeekDatesOk =
                                    weeklyRoundUps[0].startOfWeek == self.firstWeekStartDate
                                        && weeklyRoundUps[1].startOfWeek == self.secondWeekStartDate
                                        && weeklyRoundUps[2].startOfWeek == self.thirdWeekStartDate
                                return areRoundUpsOk && areStartOfWeekDatesOk
                            }))
                        expect(observer.events.last!.value).to(beCompletedEvent())
                    }
                }
            }

            describe("lastWeeklyRoundUpsRetrieved") {
                var observer: TestableObserver<[WeeklyRoundUp]>!

                beforeEach {
                    scheduler = TestScheduler(initialClock: 0)
                    observer = scheduler.createObserver([WeeklyRoundUp].self)
                }

                context("failing transactionsFetchingBusinessLogic") {
                    beforeEach {
                        transactionsFetchingStub =
                            FailingTransactionsFetchingGatewayStub()
                    }

                    context("no weeklyRoundUps() called") {
                        beforeEach {
                            businessLogic = WeeklyRoundUpsBusinessLogic(
                                gateway: transactionsFetchingStub,
                                calendar: self.calendar)
                            scheduler.start()
                        }
                        it("must be nil") {
                            expect(businessLogic.lastWeeklyRoundUpsRetrieved).to(beNil())
                        }
                    }

                    context("weeklyRoundUps() called once") {
                        beforeEach {
                            businessLogic = WeeklyRoundUpsBusinessLogic(
                                gateway: transactionsFetchingStub,
                                calendar: self.calendar)
                            businessLogic.weeklyRoundUps()
                                .subscribe(observer)
                                .disposed(by: disposeBag)
                            scheduler.start()
                        }
                        it("must be nil") {
                            expect(businessLogic.lastWeeklyRoundUpsRetrieved).to(beNil())
                        }
                    }
                }

                context("succeding transactionsFetchingBusinessLogic") {
                    beforeEach {
                        transactionsFetchingStub =
                            SucceedingTransactionsFetchingGatewayStub(
                                transactions: self.allTransactions)
                    }

                    context("no weeklyRoundUps() called") {
                        beforeEach {
                            businessLogic = WeeklyRoundUpsBusinessLogic(
                                gateway: transactionsFetchingStub,
                                calendar: self.calendar)
                            scheduler.start()
                        }
                        it("must be nil") {
                            expect(businessLogic.lastWeeklyRoundUpsRetrieved).to(beNil())
                        }
                    }

                    context("weeklyRoundUps() called once") {
                        beforeEach {
                            businessLogic = WeeklyRoundUpsBusinessLogic(
                                gateway: transactionsFetchingStub,
                                calendar: self.calendar)
                            businessLogic.weeklyRoundUps()
                                .subscribe(observer)
                                .disposed(by: disposeBag)
                            scheduler.start()
                        }
                        it("must be non-nil") {
                            expect(businessLogic.lastWeeklyRoundUpsRetrieved).toNot(beNil())
                        }
                    }
                }
            }
        }
    }
}
