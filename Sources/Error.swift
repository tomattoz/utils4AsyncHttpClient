//  Created by Ivan Kh on 25.12.2025.

import Foundation
import AsyncHTTPClient

extension HTTPClient.NWPOSIXError: @retroactive LocalizedError {
    public var errorDescription: String? {
        POSIXError(errorCode).localizedDescription
    }
}
