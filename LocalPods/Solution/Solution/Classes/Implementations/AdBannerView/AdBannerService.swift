//
//  AdBannerService.swift
//  Solution
//
//  Created by Lada Zudova on 15.02.2024.
//

import Foundation
import ProdMobileCore
import OSLog

public protocol IAdBannerService: AnyObject {
    func loadAdBannerInformation(userId: String, completion: @escaping (Result<BannerInfo, Error>) -> ())
}

final class AdBannerService: IAdBannerService {
    // Dependencies
    private let networkService: INetworkingService
    private static let logger = Logger(subsystem: "AdBannerService", category: "Networking")
    
    init(networkService: INetworkingService) {
        self.networkService = networkService
    }
    
    // MARK: - IAdBannerService
    
    func loadAdBannerInformation(userId: String, completion: @escaping (Result<BannerInfo, Error>) -> ()) {
        let request = Request(baseUrl: .baseURL, methodPath: "/banner", queryParams: ["userId": userId])
        networkService.load(request: request) { result in
            do {
                let data = try result.get()
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    AdBannerService.logger.error("Error decoding data")
                    completion(.failure(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Error decoding data"))))
                    return
                }
                guard let info = json["banner_info"] as? [String: String] else {
                    AdBannerService.logger.error("No get banner_info")
                    completion(.failure(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No get banner_info"))))
                    return
                }
                
                guard 
                    let title = info["title"],
                    let imageId = info["image_id"],
                    let description = info["description"],
                    let backgroundColor = info["background_color"]
                else {
                    let context = DecodingError.Context(
                        codingPath: [], 
                        debugDescription: "No found background_color, description, image_id or title"
                    )
                    AdBannerService.logger.error("No found background_color, description, image_id or title")
                    completion(.failure(DecodingError.dataCorrupted(context)))
                    return
                }
                AdBannerService.logger.info("Create banner")
                let bannerInfo = BannerInfo(
                    title: title,
                    description: description,
                    imageId: imageId,
                    backgroundColor: backgroundColor
                )
                completion(.success(bannerInfo))
            } catch {
                AdBannerService.logger.error("unknown error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
        }
    }
}
