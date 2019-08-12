import RxSwift
import RxAlamofire

protocol TransactionsFetchingGatewayProtocol {
    var transactions: Observable<[Transaction]> { get }
}

struct TransactionsFetchingGateway {

    private let token: String
    private let baseUrl: String
    private let transactionsEndpoint: String

    init(
        token: String = Config.token,
        baseUrl: String = Config.baseUrl,
        transactionsEndpoint: String = Config.transactionsEndpoint) {

        self.token = token
        self.baseUrl = baseUrl
        self.transactionsEndpoint = transactionsEndpoint
    }
}

extension TransactionsFetchingGateway: TransactionsFetchingGatewayProtocol {

    struct Response: Decodable {

        struct Embedded: Decodable {
            let transactions: [Transaction]
        }

        let _embedded: Embedded

        static func from(_ jsonData: Data) throws -> Response {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Custom)
            return try decoder.decode(Response.self, from: jsonData)
        }
    }

    enum TransactionsError: Error {
        case generic
    }

    var transactions: Observable<[Transaction]> {
        return RxAlamofire
            .requestData(
                .get,
                baseUrl + transactionsEndpoint,
                headers: ["Authorization": "Bearer \(token)"]
            )
            .flatMap { responseAndJsonData -> Observable<[Transaction]> in
                let (response, jsonData) = responseAndJsonData
                guard response.statusCode == 200,
                    let json = try? Response.from(jsonData) else {
                        return .error(TransactionsError.generic)
                }
                return .just(json._embedded.transactions)
            }
    }
}
