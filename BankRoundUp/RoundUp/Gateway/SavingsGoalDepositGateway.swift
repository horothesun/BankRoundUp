import RxSwift
import Alamofire
import RxAlamofire

protocol SavingsGoalDepositGatewayProtocol {
    func add(amount: Double, toGoal goalUid: UUID) -> Observable<UUID>
}

struct SavingsGoalDepositGateway {

    private let token: String
    private let baseUrl: String
    private let savingsGoalsEndpoint: String
    private let savingsGoalsAddMoneyEndpoint: String
    private let uuidGenerator: UUIDGeneratorProtocol

    init(
        token: String = Config.token,
        baseUrl: String = Config.baseUrl,
        savingsGoalsEndpoint: String = Config.savingsGoalsEndpoint,
        savingsGoalsAddMoneyEndpoint: String = Config.savingsGoalsAddMoneyEndpoint,
        uuidGenerator: UUIDGeneratorProtocol = UUIDGenerator()) {

        self.token = token
        self.baseUrl = baseUrl
        self.savingsGoalsEndpoint = savingsGoalsEndpoint
        self.savingsGoalsAddMoneyEndpoint = savingsGoalsAddMoneyEndpoint
        self.uuidGenerator = uuidGenerator
    }
}

extension SavingsGoalDepositGateway: SavingsGoalDepositGatewayProtocol {

    struct Response: Decodable {

        struct SingleError: Decodable {
            let message: String
        }

        let transferUid: UUID
        let success: Bool
        let errors: [SingleError]

        static func from(_ jsonData: Data) throws -> Response {
            let decoder = JSONDecoder()
            return try decoder.decode(Response.self, from: jsonData)
        }
    }

    enum SavingsGoalDepositError: Error {
        case generic
    }

    func add(amount: Double, toGoal goalUid: UUID) -> Observable<UUID> {
        let goalUidString = goalUid.uuidString.lowercased()
        let newTransferUidString = uuidGenerator.newUUID.uuidString.lowercased()
        let url = baseUrl
            + savingsGoalsEndpoint + goalUidString
            + savingsGoalsAddMoneyEndpoint + newTransferUidString
        return RxAlamofire
            .requestData(
                .put,
                url,
                parameters: parameters(from: amount),
                encoding: JSONEncoding(),
                headers: ["Authorization": "Bearer \(token)"]
            )
            .flatMap { responseAndJsonData -> Observable<UUID> in
                let (response, jsonData) = responseAndJsonData
                guard response.statusCode == 200,
                    let json = try? Response.from(jsonData) else {
                        return .error(SavingsGoalDepositError.generic)
                }
                return .just(json.transferUid)
            }
    }

    private func parameters(from amount: Double) -> [String: Any] {
        return [
            "amount": [
                "currency": "GBP",
                "minorUnits": 100 * amount
            ]
        ]
    }
}
