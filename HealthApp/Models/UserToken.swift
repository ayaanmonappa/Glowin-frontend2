

import Foundation

struct UserToken: Codable {
    var value: String
    var user: UserReference

    struct UserReference: Codable {
        var id: UUID
    }
}
