import RxSwift

protocol SavingsGoalDepositBusinessLogicProtocol {
    func add(amount: Double, toGoal goalUid: UUID) -> Observable<UUID>
}

struct SavingsGoalDepositBusinessLogic {

    private let gateway: SavingsGoalDepositGatewayProtocol

    init(gateway: SavingsGoalDepositGatewayProtocol = SavingsGoalDepositGateway()) {
        self.gateway = gateway
    }
}

extension SavingsGoalDepositBusinessLogic: SavingsGoalDepositBusinessLogicProtocol {

    func add(amount: Double, toGoal goalUid: UUID) -> Observable<UUID> {
        return gateway.add(amount: amount, toGoal: goalUid)
    }
}
