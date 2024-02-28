//
//  UserInfoService.swift
//  Solution
//
//  Created by Kuznetsov Mikhail on 14.02.2024.
//

import Foundation
import ProdMobileCore
import OSLog

public struct UserInfo {
    public let id: String
    public let name: String
    public let surname: String
    public let bundleCode: String
}

extension UserInfo: Identifiable {
    public var identifier: String {
        id
    }
}

extension UserInfo: Decodable {
    
}

public protocol IUserInfoService {
    func userInfo(for userId: String, _ completion: @escaping (UserInfo?) -> ())
}

final class UserInfoService: IUserInfoService {

    private let networkingService: INetworkingService
    private let storage: IPersistenceStorage
    private static let logger = Logger(subsystem: "UserInfoService", category: "Networking")
    private static let jsonDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    init(networkingService: INetworkingService, storage: IPersistenceStorage) {
        self.networkingService = networkingService
        self.storage = storage
    }

    func userInfo(for userId: String, _ completion: @escaping (UserInfo?) -> ()) {
        let usersInfo = storage.fetch(UserInfo.self)
        if !usersInfo.isEmpty {
            for userInfo in usersInfo {
                UserInfoService.logger.info("Get userInfo \(userInfo.id) from cache")
                completion(userInfo)
            }
        }
        let request = Request(baseUrl: .baseURL, methodPath: "/user/info", queryParams: ["userId": userId])
        networkingService.load(request: request) { [weak self] result in
            do {
                let data = try result.get()
                let userInfo = try UserInfoService.jsonDecoder.decode(UserInfo.self, from: data)
                UserInfoService.logger.info("Get userInfo \(userInfo.id)")
                self?.storage.save(userInfo)
                completion(userInfo)
            } catch {
                UserInfoService.logger.error("unknown error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
