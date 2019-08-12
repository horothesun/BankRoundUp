import RxSwift
import Alamofire
import RxAlamofire

protocol SavingsGoalCreationGatewayProtocol {
    func createSavingsGoal() -> Observable<UUID>
}

struct SavingsGoalCreationGateway {

    private let dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .medium
        result.timeStyle = .none
        return result
    }()

    private let token: String
    private let baseUrl: String
    private let savingsGoalsEndpoint: String
    private let uuidGenerator: UUIDGeneratorProtocol

    init(
        token: String = Config.token,
        baseUrl: String = Config.baseUrl,
        savingsGoalsEndpoint: String = Config.savingsGoalsEndpoint,
        uuidGenerator: UUIDGeneratorProtocol = UUIDGenerator()) {

        self.token = token
        self.baseUrl = baseUrl
        self.savingsGoalsEndpoint = savingsGoalsEndpoint
        self.uuidGenerator = uuidGenerator
    }
}

extension SavingsGoalCreationGateway: SavingsGoalCreationGatewayProtocol {

    struct Response: Decodable {

        struct SingleError: Decodable {
            let message: String
        }

        let savingsGoalUid: UUID
        let success: Bool
        let errors: [SingleError]

        static func from(_ jsonData: Data) throws -> Response {
            let decoder = JSONDecoder()
            return try decoder.decode(Response.self, from: jsonData)
        }
    }

    enum SavingsGoalError: Error {
        case generic
    }

    func createSavingsGoal() -> Observable<UUID> {
        let newGoalUidString = uuidGenerator.newUUID.uuidString.lowercased()
        return RxAlamofire
            .requestData(
                .put,
                baseUrl + savingsGoalsEndpoint + newGoalUidString,
                parameters: parameters,
                encoding: JSONEncoding(),
                headers: ["Authorization": "Bearer \(token)"]
            )
            .flatMap { responseAndJsonData -> Observable<UUID> in
                let (response, jsonData) = responseAndJsonData
                guard response.statusCode == 200,
                    let json = try? Response.from(jsonData) else {
                    return .error(SavingsGoalError.generic)
                }
                return .just(json.savingsGoalUid)
            }
    }

    private var parameters: [String: Any] {
        let formattedDate = dateFormatter.string(from: Date())
        return [
            "name": "Savings goal - \(formattedDate)",
            "currency": "GBP",
            "target": [
                "currency": "GBP",
                "minorUnits": 100 * 1000
            ]
        ]
    }
}
