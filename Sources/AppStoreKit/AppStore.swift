//
//  AppStore.swift
//  Buno
//
//  Created by hong on 4/8/25.
//

import Foundation

public struct AppStore {
    
    public init() {}
    
    /// 获取App信息
    /// - Parameters:
    ///   - region: 地区（默认为us）
    ///   - appIDs: appID数组
    /// - Returns: App信息
    public func fetch(region: String = "us", appIDs:[String]) async throws -> [AppResult] {
        
        let url = "https:itunes.apple.com/\(region)/lookup?id=\(appIDs.joined(separator: ","))&date=\(Date.init().timeIntervalSince1970)"

        let (data, response) = try await session.data(from: URL(string: url)!)
        
        guard let response = response as? HTTPURLResponse else {
            throw generateError(description: "Bad Response")
        }
        
        switch response.statusCode {
        case 200:
            do {
                let decoder = JSONDecoder()
                let appInfo = try decoder.decode(AppInfo.self, from: data)
                return appInfo.results
            } catch {
                throw generateError(description: "Analyse Error")
            }
        default:
            throw generateError(description: "A Server Error Occured")
        }
    }

    // MARK: Private

    private let session = URLSession.shared

    private func generateError(code: Int = -1, description: String) -> Error {
        NSError(domain: "ChannelAPPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}

public struct AppResult: Codable, Hashable {
    public let trackName: String
    public let trackId: Int64
    public let artworkUrl512: String
    public let version: String
}

public struct AppInfo: Codable {
    public let results: [AppResult]
}
