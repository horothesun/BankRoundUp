import Foundation

struct Transaction: Decodable {

    enum Direction: String, Decodable {
        case outbound = "OUTBOUND"
        case inbound = "INBOUND"
        case none = "NONE"
    }

    enum Source: String, Decodable {
        case DIRECT_CREDIT
        case DIRECT_DEBIT
        case DIRECT_DEBIT_DISPUTE
        case INTERNAL_TRANSFER
        case MASTER_CARD
        case FASTER_PAYMENTS_IN
        case FASTER_PAYMENTS_OUT
        case FASTER_PAYMENTS_REVERSAL
        case STRIPE_FUNDING
        case INTEREST_PAYMENT
        case NOSTRO_DEPOSIT
        case OVERDRAFT
    }

    let id: UUID
    let currency: String
    let amount: Double
    let direction: Direction
    let created: Date
    let narrative: String
    let source: Source
    let balance: Double
}
