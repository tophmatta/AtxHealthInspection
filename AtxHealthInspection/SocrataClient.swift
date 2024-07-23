//
//  SocrataClient.swift
//  AtxHealthInspection
//
//  Created by Toph Matta on 7/7/24.
//

import Foundation
import CoreLocation

protocol ISocrataClient {
    func searchByName(_ value: String) async throws -> [Report]
    func prepareForRequest(_ value: String) -> String
}

enum SearchError: Error, LocalizedError {
    case invalidUrl, decodingError, emptyValue, invalidLocation, invalidResponse, networkError, emptyResponse
    
    var errorDescription: String? {
        switch self {
        case .emptyValue:
            return "The search value cannot be empty. Please enter a value."
        case .emptyResponse:
            return "Your search did not yield any results."
        case .networkError:
            return "A network error occurred. Please check your connection and try again."
        default:
            return "Unknown Error"
        }
    }

}

struct SocrataClient: ISocrataClient {
    func searchByName(_ value: String) async throws -> [Report] {
        guard value.isNotEmpty else { throw SearchError.emptyValue }
        
        let searchName = prepareForRequest(value)
        let query = "lower(restaurant_name) like '%\(searchName)%'"
        let result: [Report]
        
        do {
            result = try await get(query)
        } catch {
            throw error
        }
        return result
    }
    
    private func get(_ rawQuery: String) async throws -> [Report] {
        try await Task(priority: .background) {
            guard
                let url =
                UrlBuilder
                    .create()
                    .addQuery(rawQuery)
                    .build()
            else { throw SearchError.invalidUrl }
            
            let result: [Report]
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw SearchError.invalidResponse
                }
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                result = try decoder.decode([Report].self, from: data)
                
                guard !result.isEmpty else {
                    throw SearchError.emptyResponse
                }
            } catch DecodingError.dataCorrupted(_),
                    DecodingError.keyNotFound(_, _),
                    DecodingError.typeMismatch(_, _),
                    DecodingError.valueNotFound(_, _) {
                throw SearchError.decodingError
            } catch {
                throw error
            }
            return result
        }.value
    }
    
    func searchByLocation(_ location: CLLocationCoordinate2D) async throws -> Report? {
        guard location.isValid() else { throw SearchError.invalidLocation }
        
        let query = "within_circle(null, \(location.latitude), \(location.longitude), 1000)"
        return try! await get(query).first
    }
    
    nonisolated func prepareForRequest(_ value: String) -> String {
        return value
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "^the ", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\u{2019}s", with: "")
            .replacingOccurrences(of: "'s", with: "")
    }
}
