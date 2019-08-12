import RxSwift
@testable import BankRoundUp

struct FailingTransactionsFetchingGatewayStub: TransactionsFetchingGatewayProtocol {
    var transactions: Observable<[Transaction]> {
        return .error(FakeError.generic)
    }
}

struct SucceedingTransactionsFetchingGatewayStub {
    private let transactionList: [Transaction]

    init(transactions: [Transaction]) {
        transactionList = transactions
    }
}

extension SucceedingTransactionsFetchingGatewayStub: TransactionsFetchingGatewayProtocol {
    var transactions: Observable<[Transaction]> {
        return .just(transactionList)
    }
}
