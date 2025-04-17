//  Created by Ivan Kh on 04.10.2024.

import Foundation
import AsyncHTTPClient
import NIOHTTP1

public extension HTTPClientResponse.Body {
    func collectString() async throws -> String {
        String(buffer: try await collect(upTo: .max))
    }
}

public extension HTTPResponseStatus {
    var isOK: Bool {
        code >= 200 && code < 300
    }
}
