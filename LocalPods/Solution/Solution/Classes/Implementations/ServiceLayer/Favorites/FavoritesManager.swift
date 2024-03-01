//
//  FavoritesManager.swift
//  Solution
//
//  Created by Kuznetsov Mikhail on 14.02.2024.
//

import Foundation
import ProdMobileCore
import OSLog

public protocol IFavoritesDelegate: AnyObject {
    func favoritesDidChanged()
}

struct FavoritesModel: Identifiable {
    let identifier: String
}

public protocol IFavoritesManager {
    /// Возвращает сохраненные айдишники офферов из избранного
    var favorites: [String] { get }
    /// Возвращает количество офферов в избранном
    var favoritesCount: Int { get }
    /// Метод подписки на уведомления об изменении  данных в избранном
    func subscribe(_ delegate: IFavoritesDelegate)
    /// Добавление в избранное
    func likeOffer(with id: String)
    /// Удаление из избранного
    func unlikeOffer(with id: String)
}

final class FavoritesManager: IFavoritesManager {
    
    // Dependencies
    private var delegateList: [WeakFavoritesDelegate] = []
    private let storage: IPersistenceStorage
    private let dataBaseQueue = DispatchQueue(label: "storage", qos: .default)
    private static let logger = Logger(subsystem: "FavoritesManager", category: "Logic")

    init(storage: IPersistenceStorage) {
        self.storage = storage
    }

    var favorites: [String] {
        return storage.fetch(FavoritesModel.self).map { $0.identifier }
    }
    
    var favoritesCount: Int {
        favorites.count
    }

    func subscribe(_ delegate: IFavoritesDelegate) {
        let weakDelegate = WeakFavoritesDelegate(delegate)
        delegateList.append(weakDelegate)
    }

    func likeOffer(with id: String) {
        dataBaseQueue.async { [weak self] in
            guard let self else {
                FavoritesManager.logger.warning("self is weak")
                return
            }
            FavoritesManager.logger.info("saving FavoritesModel \(id)")
            self.storage.save(FavoritesModel(identifier: id))
            notifySubscribe()
        }
    }

    func unlikeOffer(with id: String) {
        dataBaseQueue.async { [weak self] in
            guard let self else {
                FavoritesManager.logger.warning("self is weak")
                return
            }
            FavoritesManager.logger.info("deleting FavoritesModel \(id)")
            self.storage.delete(FavoritesModel(identifier: id))
            notifySubscribe()
        }
    }
    
    private func notifySubscribe() {
        DispatchQueue.main.sync {
            delegateList.forEach { weakDelegate in
                guard let delegate = weakDelegate.value else {
                    return
                }
                delegate.favoritesDidChanged()
            }
        }
    }

}

struct WeakFavoritesDelegate {
    weak var value: IFavoritesDelegate?

    init(_ value: IFavoritesDelegate?) {
        self.value = value
    }
}
