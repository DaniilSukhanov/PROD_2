//
//  OperationsService.swift
//  Solution
//
//  Created by Kuznetsov Mikhail on 14.02.2024.
//

import Foundation
import ProdMobileCore
import OSLog

public enum Operation {
    public enum Currency {
        case specialPoint
        case rub
    }

    case receipt(value: Double, currency: Currency)
    case withdrawal(value: Double, currency: Currency)
}

/// Обертка для кэширования 
struct OperationCache: Identifiable {
    let identifier: String
    let operation: Operation
}

public protocol IOperationsService {
    func currentAccount(for userId: String, _ completion: @escaping ([Operation]) -> ())
}

final class OperationsService: IOperationsService {

    private let networkingService: INetworkingService
    private let storage: IPersistenceStorage
    private static let logger = Logger(subsystem: "OperationsService", category: "Networking")

    init(networkingService: INetworkingService, storage: IPersistenceStorage) {
        self.networkingService = networkingService
        self.storage = storage
    }

    func currentAccount(for userId: String, _ completion: @escaping ([Operation]) -> ()) {
        let operationsCache = storage.fetch(OperationCache.self)
        if !operationsCache.isEmpty {
            OperationsService.logger.info("fetch operations from cache")
            completion(
                operationsCache.map {
                    $0.operation
                }
            )
            return
        }
        let request = Request(baseUrl: .baseURL, methodPath: "/operations/list", queryParams: ["userID": userId])
        networkingService.load(request: request) { [weak self] result in
            do {
                let data = try result.get()
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    OperationsService.logger.error("Error decoding data")
                    completion([])
                    return
                }
                guard let operations = json["operations"] as? [[String: Any]] else {
                    OperationsService.logger.error("Not found operations in json")
                    completion([])
                    return
                }
                var result = [Operation]()
                for item in operations.enumerated() {
                    let jsonOperation = item.element
                    guard let tupleOperation = OperationsService.decodeOperation(operation: jsonOperation) else {
                        OperationsService.logger.error("Not decode operation: \(jsonOperation)")
                        continue
                    }
                    guard let operation = OperationsService.createOperation(operation: tupleOperation) else {
                        OperationsService.logger.error(
                            "Invalid formate operation: currency=\(tupleOperation.currency) direction=\(tupleOperation.direction) value=\(tupleOperation.value)"
                        )
                        continue
                    }
                    result.append(operation)
                    self?.storage.save(OperationCache(identifier: String(item.offset), operation: operation))
                }
                OperationsService.logger.info("send operations from networking")
                completion(result)
            } catch {
                OperationsService.logger.error("unknown error: \(error.localizedDescription)")
                completion([])
            }
        }
    }
    
    private static func decodeOperation(operation: [String: Any]) -> (currency: String, direction: String, value: Double)? {
        guard
            let currency = operation["currency"] as? String,
            let direction = operation["direction"] as? String,
            let value = operation["value"] as? Double
        else {
            return nil
        }
        return (currency, direction, value)
    }
    
    private static func createOperation(operation: (currency: String, direction: String, value: Double)) -> Operation? {
        guard let currency = OperationsService.createCurrency(currency: operation.currency) else {
            OperationsService.logger.error("Bad currency: \(operation.currency)")
            return nil
        }
        switch operation.direction {
        case "receipt":
            return .receipt(value: operation.value, currency: currency)
        case "withdrawal":
            return .withdrawal(value: operation.value, currency: currency)
        default:
            OperationsService.logger.error("Bad direction: \(operation.direction)")
            return nil
        }
        
    }
    
    private static func createCurrency(currency: String) -> Operation.Currency? {
        switch currency {
        case "rub":
            return Operation.Currency.rub
        case "special_point":
            return Operation.Currency.specialPoint
        default:
            return nil
        }
    }
}
