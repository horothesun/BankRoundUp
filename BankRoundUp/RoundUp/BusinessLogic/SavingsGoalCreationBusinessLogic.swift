import RxSwift

protocol SavingsGoalCreationBusinessLogicProtocol {
    func createSavingsGoal() -> Observable<UUID>
}

struct SavingsGoalCreationBusinessLogic {

    private let gateway: SavingsGoalCreationGatewayProtocol

    init(gateway: SavingsGoalCreationGatewayProtocol = SavingsGoalCreationGateway()) {
        self.gateway = gateway
    }
}

extension SavingsGoalCreationBusinessLogic: SavingsGoalCreationBusinessLogicProtocol {

    func createSavingsGoal() -> Observable<UUID> {
        return gateway.createSavingsGoal()
    }
}
