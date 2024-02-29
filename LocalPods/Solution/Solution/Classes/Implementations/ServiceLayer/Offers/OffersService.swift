//
//  OffersService.swift
//  Solution
//
//  Created by Kuznetsov Mikhail on 14.02.2024.
//

import Foundation
import ProdMobileCore
import OSLog

fileprivate struct Description: Decodable {
    let short: String
}

public struct OfferShortInfo {
    let id: String
    let image: String
    let supplier: Supplier
    let shortDescription: String
    let status: String
    let type: String
    let bonus: OfferBonus
    let restrictions: [OfferRestriction]
}

extension OfferShortInfo: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case image = "offer_image"
        case supplier = "supplier_info"
        case shortDescription = "description"
        case status
        case type
        case bonus = "bonuses"
        case restrictions
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        image = try container.decode(String.self, forKey: .image)
        supplier = try container.decode(Supplier.self, forKey: .supplier)
        shortDescription = try container.decode(Description.self, forKey: .shortDescription).short
        status = try container.decode(String.self, forKey: .status)
        type = try container.decode(String.self, forKey: .type)
        bonus = try container.decode(OfferBonus.self, forKey: .bonus)
        restrictions = try container.decode([OfferRestriction].self, forKey: .restrictions)
    }
}

public struct OfferFullDetails {
    let id: String
    let image: String
    let supplier: Supplier
    let fullDescription: String
    let status: String
    let type: String
    let bonus: OfferBonus
    let restrictions: [OfferRestriction]
    let terms: [(type: String, value: String)]
    let promocode: String
}

extension OfferFullDetails: Decodable {
    struct Term: Decodable {
        let type: String
        let value: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case image = "offer_image"
        case supplier = "supplier_info"
        case fullDescription = "description"
        case status
        case type
        case bonus = "bonuses"
        case restrictions
        case terms
        case promocode
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        image = try container.decode(String.self, forKey: .image)
        supplier = try container.decode(Supplier.self, forKey: .supplier)
        fullDescription = try container.decode(Description.self, forKey: .fullDescription).short
        status = try container.decode(String.self, forKey: .status)
        type = try container.decode(String.self, forKey: .type)
        bonus = try container.decode(OfferBonus.self, forKey: .bonus)
        restrictions = try container.decode([OfferRestriction].self, forKey: .restrictions)
        promocode = try container.decode(String.self, forKey: .promocode)
        terms = try container.decode([Term].self, forKey: .terms).map {
            (type: $0.type, value: $0.value)
        }
    }
}

struct Supplier {
    let name: String
    let baseColor: String
}

extension Supplier: Decodable {
    
}

enum OfferRestriction {
    case forBundles(bundlesIds: [String], newValue: Double)
}

extension OfferRestriction: Decodable {
    struct Value: Decodable {
        enum CodingKeys: String, CodingKey {
            case newValue = "newValue"
            case bundlesIds = "bundles_ids"
        }
        let newValue: Double
        let bundlesIds: [String]
    }
    
    enum CodingKeys: String, CodingKey {
        case `type`, value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let `type` = try container.decode(String.self, forKey: .type)
        let value = try container.decode(Value.self, forKey: .value)
        switch type {
        case "for_bundles":
            self = .forBundles(bundlesIds: value.bundlesIds, newValue: value.newValue)
        default:
            throw DecodingError.typeMismatch(Value.self, .init(codingPath: [], debugDescription: "no correct type"))
        }
    }
}

enum OfferBonus {
    case specialPoints(Double)
    case cashback(Double)
}

extension OfferBonus: Decodable {
    enum CodingKeys: String, CodingKey {
        case `type`, value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let `type` = try container.decode(String.self, forKey: .type)
        let value = try container.decode(Double.self, forKey: .value)
        switch type {
        case "cashback":
            self = .cashback(value)
        case "special_points":
            self = .specialPoints(value)
        default:
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.type], debugDescription: "Not correct type in OfferBonus"))
        }
    }
}

public protocol IOffersService {
    func offers(for userId: String, _ completion: @escaping ([OfferShortInfo]) -> ())
    func offersRecomendation(for userId: String, _ completion: @escaping ([OfferShortInfo]) -> ())
    func details(for offer: String, _ userId: String, _ completion: @escaping (OfferFullDetails?) -> ())
}

final class OffersService: IOffersService {
    private let networkingService: INetworkingService
    private let storage: IPersistenceStorage
    private static let jsonDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    private static let logger = Logger(subsystem: "OffersService", category: "Networking")

    init(networkingService: INetworkingService, storage: IPersistenceStorage) {
        self.networkingService = networkingService
        self.storage = storage
    }

    func offers(for userId: String, _ completion: @escaping ([OfferShortInfo]) -> ()) {
        let queryParams: [String: String] =  [
            "recomendation": "false",
            "userId": userId
        ]
        let request = Request(baseUrl: .baseURL, methodPath: "/offers/list", queryParams: queryParams)
        networkingService.load(request: request) { result in
            do {
                let data = try result.get()
                let shortInfos = try OffersService.jsonDecoder.decode([OfferShortInfo].self, from: data)
                OffersService.logger.info("get array OfferShortInfo from networking")
                completion(shortInfos)
            } catch {
                OffersService.logger.error("unknown error: \(error.localizedDescription)")
                completion([])
            }
        }
    }

    func offersRecomendation(for userId: String, _ completion: @escaping ([OfferShortInfo]) -> ()) {
        let queryParams: [String: String] =  [
            "recomendation": "true",
            "userId": userId
        ]
        let request = Request(baseUrl: .baseURL, methodPath: "/offers/list", queryParams: queryParams)
        networkingService.load(request: request) { result in
            do {
                let data = try result.get()
                let shortInfos = try OffersService.jsonDecoder.decode([OfferShortInfo].self, from: data)
                OffersService.logger.info("get array OfferShortInfo from networking")
                completion(shortInfos)
            } catch {
                OffersService.logger.error("unknown error: \(error.localizedDescription)")
                completion([])
            }
        }
    }

    func details(for offer: String, _ userId: String, _ completion: @escaping (OfferFullDetails?) -> ()) {
        let queryParams: [String: String] =  [
            "id": offer,
            "userId": userId
        ]
        let request = Request(baseUrl: .baseURL, methodPath: "/offers", queryParams: queryParams)
        networkingService.load(request: request) { result in
            do {
                let data = try result.get()
                let detailInfo = try OffersService.jsonDecoder.decode(OfferFullDetails.self, from: data)
                OffersService.logger.info("get array OfferFullDetails from networking")
                completion(detailInfo)
            } catch {
                OffersService.logger.error("unknown error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
