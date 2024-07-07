//
//  SocrataClient.swift
//  AtxHealthInspection
//
//  Created by Toph Matta on 7/7/24.
//

import Foundation


protocol ISocrataClient {
    func get(_ value: String) async -> Result<Report, SearchError>
    func prepareForRequest(_ value: String) -> String
}

enum SearchError: Error {
    case invalidUrl, decodingError, emptyValue
}

struct SocrataClient: ISocrataClient {
    
    func get(_ value: String) async -> Result<Report, SearchError> {
        return await Task.detached(priority: .background) {
            guard value.isNotEmpty else { return .failure(.emptyValue) }
            
            let searchName = prepareForRequest(value)
            
            // Lowercase the column to match param
            let query = "lower(restaurant_name) like '%\(searchName)%'"
            
            guard
                let url = UrlBuilder
                            .create()
                            .addQuery(query)
                            .build()
            else { return .failure(.invalidUrl) }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                            
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode([Report].self, from: data)
                
                guard !result.isEmpty else { return .failure(.decodingError) }
                
                return .success(result.first!)
            } catch {
                return .failure(.decodingError)
            }
        }.value
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