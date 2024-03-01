//
//  BundlesService.swift
//  Solution
//
//  Created by Kuznetsov Mikhail on 14.02.2024.
//

import Foundation
import ProdMobileCore
import OSLog

public struct SpecialBundle: Identifiable {
    public let code: String
    public let name: String
    public let base_color: String
    public let secondary_color: String

    public var identifier: String { code }
}

extension SpecialBundle: Decodable {
    enum CodingKeys: String, CodingKey {
        case code, name, base_color, secondary_color
    }
}

public protocol IBundlesService {
    func bundles(_ completion: @escaping ([SpecialBundle]) -> ())
}

final class BundlesService: IBundlesService {
    
    private let networkingService: INetworkingService
    private let storage: IPersistenceStorage
    private static let jsonDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    private static let logger = Logger(subsystem: "BundlesService", category: "Networking")

    init(networkingService: INetworkingService, storage: IPersistenceStorage) {
        self.networkingService = networkingService
        self.storage = storage
    }

    func bundles(_ completion: @escaping ([SpecialBundle]) -> ()) {
        let items = storage.fetch(SpecialBundle.self)
        if !items.isEmpty {
            BundlesService.logger.info("Get SpecialBundles from cache")
            completion(items)
            return
        }
        let request = Request(baseUrl: .baseURL, methodPath: "/bundles", queryParams: [:])
        networkingService.load(request: request) { [weak self] result in
            do {
                let data = try result.get()
                let specialBundles = try BundlesService.jsonDecoder.decode([SpecialBundle].self, from: data)
                for specialBundle in specialBundles {
                    self?.storage.save(specialBundle)
                }
                BundlesService.logger.info("Get SpecialBundles")
                completion(specialBundles)
            } catch {
                BundlesService.logger.error("unknown error: \(error.localizedDescription)")
                completion([])
            }
        }
    }
}
