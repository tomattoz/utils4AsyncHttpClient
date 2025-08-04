//  Created by Ivan Khvorostinin on 07.05.2025.

import Foundation
import AsyncHTTPClient
import NIOHTTP1
import Utils9
import Utils9AIAdapter

public protocol HttpProvider {
    func post<T: StringHashable & Encodable>(at path: String, data: T) throws
    -> HTTPClientRequest

    func execute(_ request: HTTPClientRequest) async throws
    -> HTTPClientResponse
}

open class HttpProviderImpl: ObservableObject, HttpProvider {
    private var urlString: StringVar
    private let salt: String

    public init(url: StringVar, salt: String) {
        self.urlString = url
        self.salt = salt
    }
    
    public func request(for path: String) -> HTTPClientRequest {
        let url = URL(string: urlString.value)!
        return HTTPClientRequest(url: url.appendingPathComponent(path).absoluteString)
    }

    public func post<T: StringHashable & Encodable>(at path: String, data: T) throws
    -> HTTPClientRequest {
        var request = request(for: path)
        let requestBytes = try JSONEncoder().encode(data)

        request.headers.add(name: .httpHeaderContentType, value: "application/json")
        request.headers.add(name: .httpHeaderContentHash, value: data.stringHash(salt: salt))
        request.body = .bytes(requestBytes)
        request.method = .POST

        return request
    }

    public func execute(_ request: HTTPClientRequest) async throws
    -> HTTPClientResponse {
        do {
            return try await _execute(request)
        }
        catch {
            log(error)
            throw error
        }
    }
    
    func _execute(_ request: HTTPClientRequest) async throws -> HTTPClientResponse {
        let response = try await HTTPClient.shared.execute(request, timeout: .seconds(60))

        if !response.status.isOK {
            let slice = try await response.body.collect(upTo: .max)
            log(error: String(buffer: slice))
            let error = try JSONDecoder().decode(ServerError.self, from: slice)

            switch error {
            case .http(let error): throw error
            case .registration(let error): throw error
            case .content(let error): throw error
            case .openai(let error): throw error
            case .openai2(let error): throw error
            case .generic(let error): throw error
            }
        }
        
        return response
    }
    
    public func object<T: Decodable & StringHashable>(_ request: HTTPClientRequest)
    async throws -> T {
        let response = try await execute(request)
        let result: T = try await JSONDecoder().decode(
            T.self,
            from: try response.body.collect(upTo: .max))
        
        guard result.stringHash(salt: salt) == response.headers.first(name: .httpHeaderContentHash) else {
            throw HTTPError.invalidHash
        }
        
        return result
    }
}

