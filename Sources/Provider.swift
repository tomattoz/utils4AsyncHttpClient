//  Created by Ivan Khvorostinin on 07.05.2025.

import Foundation
import AsyncHTTPClient
import NIOHTTP1
import Utils9
import Utils9AIAdapter

open class HTTPTransportNIO: HTTPTransport {
    public init() {}
    
    public func data(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, data: Data) {
        let response = try await _execute(request)
        return await (
            response: .init(response, url: request.url!),
            data: Data(buffer: try response.body.collect(upTo: Int.max))
        )
    }
    
    public func stream(_ request: URLRequest) async throws
    -> (response: HTTPURLResponse, stream: AsyncThrowingStream<Data, Error>) {
        let response = try await _execute(request)
        return (
            response: .init(response, url: request.url!),
            stream: response.body.stream
        )
    }
}

private extension HTTPTransportNIO {    
    func _execute(_ request: URLRequest) async throws -> HTTPClientResponse {
        let clientRequest = HTTPClientRequest(request)
        return try await HTTPClient.shared.execute(clientRequest, timeout: .seconds(60))
    }
}

private extension NIOHTTP1.HTTPMethod {
    init(_ src: Utils9AIAdapter.HTTPMethod) {
        switch src {
        case .get:
            self = .GET
        case .post:
            self = .POST
        case .put:
            self = .PUT
        case .patch:
            self = .PATCH
        case .delete:
            self = .DELETE
        case .head:
            self = .HEAD
        case .options:
            self = .OPTIONS
        case .trace:
            self = .TRACE
        case .connect:
            self = .CONNECT
        }
    }
}

extension HTTPURLResponse {
    convenience init(_ src: HTTPClientResponse, url: URL) {
        let versionString: String
        switch src.version {
        case .http1_0: versionString = "HTTP/1.0"
        case .http1_1: versionString = "HTTP/1.1"
        case .http2: versionString = "HTTP/2"
        case .http3: versionString = "HTTP/3"
        default: versionString = "HTTP/1.1"
        }

        var headerFields: [String: String] = [:]
        for (name, value) in src.headers {
            if headerFields[name] == nil {
                headerFields[name] = value
            }
        }

        self.init(
            url: url,
            statusCode: Int(src.status.code),
            httpVersion: versionString,
            headerFields: headerFields
        )!
    }
}

extension HTTPClientRequest {
    init(_ src: URLRequest) {
        self.init(url: src.url!.absoluteString)
        
        if let method = src.httpMethod {
            self.method = .RAW(value: method)
        }
        
        if let headers = src.allHTTPHeaderFields {
            for (name, value) in headers {
                self.headers.add(name: name, value: value)
            }
        }
        
        if let body = src.httpBody {
            self.body = .bytes(body)
        }
    }
}

private extension HTTPClientResponse.Body {
    var stream: AsyncThrowingStream<Data, Error> {
        .init { continuation in
            Task {
                do {
                    for try await buffer in self {
                        continuation.yield(.init(buffer: buffer))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
    }
}
