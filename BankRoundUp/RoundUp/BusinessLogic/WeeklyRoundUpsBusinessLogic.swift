import Foundation
import RxSwift

protocol WeeklyRoundUpsBusinessLogicProtocol {
    func weeklyRoundUps() -> Observable<[WeeklyRoundUp]>
    var lastWeeklyRoundUpsRetrieved: [WeeklyRoundUp]? { get }
}

final class WeeklyRoundUpsBusinessLogic {

    private(set) var lastWeeklyRoundUpsRetrieved: [WeeklyRoundUp]?

    private let gateway: TransactionsFetchingGatewayProtocol
    private let calendar: Calendar

    init(
        gateway: TransactionsFetchingGatewayProtocol
            = TransactionsFetchingGateway(),
        calendar: Calendar = Calendar.current) {

        self.gateway = gateway
        self.calendar = calendar
    }
}

extension WeeklyRoundUpsBusinessLogic: WeeklyRoundUpsBusinessLogicProtocol {

    func weeklyRoundUps() -> Observable<[WeeklyRoundUp]> {
        return gateway.transactions
            .map(weeklyRoundUps(fromTransactions:))
            .do(onNext: { [weak self] weeklyRoundUps in
                self?.lastWeeklyRoundUpsRetrieved = weeklyRoundUps
            })
    }

    private func weeklyRoundUps(fromTransactions transactions: [Transaction]) -> [WeeklyRoundUp] {
        return transactions
            .filter { $0.direction == .outbound }
            .groupBy { $0.created.startOfWeek(calendar: self.calendar)! }
            .map { startOfWeekDateAndTransactionGroup -> WeeklyRoundUp in
                let (startOfWeekDate, transactionGroup) = startOfWeekDateAndTransactionGroup
                return WeeklyRoundUp(
                    startOfWeek: startOfWeekDate,
                    amount: self.roundUp(fromInboundTransactions: transactionGroup))
            }
    }

    private func roundUp(fromInboundTransactions inboundTransactions: [Transaction]) -> Double {
        return inboundTransactions
            .map { $0.amount }
            .map(roundUp(forAmount:))
            .reduce(0.0, +)
    }

    private func roundUp(forAmount amount: Double) -> Double {
        let absAmount = abs(amount)
        return ceil(absAmount) - absAmount
    }
}
