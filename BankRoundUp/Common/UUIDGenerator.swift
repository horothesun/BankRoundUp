import Foundation

protocol UUIDGeneratorProtocol {
    var newUUID: UUID { get }
}

struct UUIDGenerator: UUIDGeneratorProtocol {
    var newUUID: UUID {
        return UUID()
    }
}
