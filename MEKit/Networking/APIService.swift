//
//  APIService.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

typealias Payload = [String: Any]
typealias List = [Payload]

// MARK: - API Error

enum APIServiceError: Error {
    case noData
    case invalidData(description: String)
    
    var localizedDescription: String {
        switch self {
        case .noData: return "No data"
        case .invalidData(let description): return "Invalid data: \(description)"
        }
    }
}

// MARK: - API Request

protocol APIRequestProtocol {
    func cancel()
}

class APIRequest: APIRequestProtocol {
    let dataTask: URLSessionDataTask
    
    init(dataTask: URLSessionDataTask) {
        self.dataTask = dataTask
    }
    
    func cancel() {
        dataTask.cancel()
    }
}

// MARK: - API Response

protocol APIResponseBase {
    init(_ data: Data) throws
}

// MARK: - API Endpoint

enum APIHTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PUT = "PUT"
    case PATCH = "PATCH"
}

protocol APIEndpoint {
    associatedtype ResultType: APIResponseBase

    func createURLRequest(baseURL: URL) -> URLRequest
    
    var path: String {get}
    var method: APIHTTPMethod {get}
    var queryParameters: [String: Any]? {get}
    var bodyData: Data? {get}
}

extension APIEndpoint {
    var method: APIHTTPMethod { return .GET } 
    var queryParameters: [String: Any]? { return nil }
    var bodyData: Data? { return nil }
    
    func createURLRequest(baseURL: URL) -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
       
        if !path.isEmpty {
            urlComponents.path.append(path)
        }
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            var queryItems: [URLQueryItem] = []
            
            for (key, value) in queryParameters {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            
            urlComponents.queryItems = queryItems
        }
                       
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        
        if let bodyData = bodyData {
            request.httpBody = bodyData
        }
        
        return request
    }
}

// MARK: - API Behaviors

protocol APIRequestBehavior {
    func before(request: URLRequest) -> URLRequest
}

// MARK: - API Service

protocol APIServiceProtocol {
    @discardableResult func load<E: APIEndpoint>(endpoint: E, completion: @escaping (Result<E.ResultType, Error>)->()) -> APIRequestProtocol
}

class APIService: APIServiceProtocol {
    let baseURL: URL
    let behaviors: [APIRequestBehavior]

    init(baseURL: URL, behaviors: [APIRequestBehavior] = []) {
        self.baseURL = baseURL
        self.behaviors = behaviors
    }
    
    @discardableResult
    func load<E: APIEndpoint>(endpoint: E, completion: @escaping (Result<E.ResultType, Error>)->()) -> APIRequestProtocol {
        
        var urlRequest = endpoint.createURLRequest(baseURL: baseURL)

        behaviors.forEach {
            urlRequest = $0.before(request: urlRequest)
        }

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, URLResponse, requestError in
            var result: Result<E.ResultType, Error>!
            
            if let requestError = requestError {
                result = .failure(requestError)
            } else {
                if let data = data {
                    do {
                        let response = try E.ResultType.init(data)
                        result = .success(response)
                    } catch {
                        result = .failure(error)
                    }
                } else {
                    result = .failure(APIServiceError.noData)
                }
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        dataTask.resume()
        
        return APIRequest(dataTask: dataTask)
    }
    
}
