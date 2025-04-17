//  Created by Ivan Khvorostinin on 14.04.2025.

import Foundation
import NIO
import saiUtils

public extension JSONDecoder {
    func decodeX<T: Decodable>(_ type: T.Type, from buffer: ByteBuffer) throws -> T {
        do {
            return try decode(type, from: buffer)
        }
        catch {
            let nsError = error as NSError
            
            if nsError.domain == NSCocoaErrorDomain, nsError.code == 3840 {
                throw ContentError.decoding(String(buffer: buffer))
            }
            
            throw error
        }
    }
}
