//
//  SpecialOffersListInteractor.swift
//  Solution
//
//  Created by Kuznetsov Mikhail on 17.02.2024.
//

import UIKit
import ProdMobileCore
import OSLog

public protocol ISpecialOffersListInteractor {
    var router: IMainRouter? { get set }
    func prepareConfiguration(
        userId: String,
        with output: ISpecialOffersListInteractorOutput,
        completion: @escaping ([SpecialOfferViewModel]) -> Void
    )
}

public protocol ISpecialOffersListInteractorOutput: AnyObject {
    func update(offers: [SpecialOfferViewModel])
}

final class SpecialOffersListInteractor: ISpecialOffersListInteractor {
    
    
    private let offersService: IOffersService
    private let offersManager: IOffersManager
    private let bundlesService: IBundlesService
    private let userInfoService: IUserInfoService
    private let favoritesManager: IFavoritesManager
    private let imageFactory: IImageFactory
    private let offerDetailsAssembly: IOfferDetailsAssembly
    private weak var output: ISpecialOffersListInteractorOutput?
    private static let logger = Logger(subsystem: "SpecialOffersListInteractor", category: "Logic")
    
    private var userId: String?
    private var offers: [OfferShortInfo] = []
    private var userBundle: SpecialBundle?
    
    var router: IMainRouter?
    
    init(
        offersService: IOffersService,
        offersManager: IOffersManager,
        bundlesService: IBundlesService,
        userInfoService: IUserInfoService,
        favoritesManager: IFavoritesManager,
        imageFactory: IImageFactory,
        offerDetailsAssembly: IOfferDetailsAssembly
    ) {
        self.offersService = offersService
        self.offersManager = offersManager
        self.bundlesService = bundlesService
        self.userInfoService = userInfoService
        self.favoritesManager = favoritesManager
        self.imageFactory = imageFactory
        self.offerDetailsAssembly = offerDetailsAssembly
        favoritesManager.subscribe(self)
    }
    
    func prepareConfiguration(
        userId: String,
        with output: ISpecialOffersListInteractorOutput,
        completion: @escaping ([SpecialOfferViewModel]) -> Void
    ) {
        let group = DispatchGroup()
        var offers: [OfferShortInfo]?, userInfo: UserInfo?, bundlesUser: [SpecialBundle]?
        
        var isFirstCall1 = true
        group.enter()
        offersService.offersRecomendation(for: userId) { result in
            if !isFirstCall1 {
                return
            }
            isFirstCall1 = false
            offers = result
            group.leave()
        }
        
        var isFirstCall2 = true
        group.enter()
        userInfoService.userInfo(for: userId) { result in
            if !isFirstCall2 {
                return
            }
            isFirstCall2 = false
            userInfo = result
            group.leave()
        }
        
        var isFirstCall3 = true
        group.enter()
        bundlesService.bundles { result in
            if !isFirstCall3 {
                return
            }
            isFirstCall3 = false
            bundlesUser = result
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let userInfo, let bundlesUser, let offers, let self else {
                return
            }
            let specialBundle = bundlesUser.filter { $0.code == userInfo.bundleCode }.first
            let filtredOffers = self.offersManager.filter(offers: offers, for: specialBundle)
            let viewModels = filtredOffers.map { offer in
                var discountValue: String
                switch offer.bonus {
                case .specialPoints(let double):
                    discountValue = String(double) + " бал."
                case .cashback(let double):
                    discountValue = String(double) + " %"
                }
                var viewModel: SpecialOfferViewModel
                viewModel = SpecialOfferViewModel(
                    title: offer.supplier.name,
                    discountValue: discountValue,
                    description: offer.shortDescription,
                    bundleName: specialBundle?.name,
                    bundleBaseColor: specialBundle?.base_color == nil ? nil : UIColor(hexString: specialBundle!.base_color),
                    bundleSecondaryColor: specialBundle?.secondary_color == nil ? nil : UIColor(hexString: specialBundle!.secondary_color),
                    image: self.imageFactory.offerImage(id: offer.image),
                    backgroundColor: UIColor(hexString: offer.supplier.baseColor)!,
                    isFavorite: self.favoritesManager.favorites.contains(offer.id),
                    onTap: {
                        #warning ("TODO: do something on Tap")
                    },
                    favouriteTap: {
                        SpecialOffersListInteractor.logger.info("favouriteTap")
                        if self.favoritesManager.favorites.contains(offer.id) {
                            self.favoritesManager.unlikeOffer(with: offer.id)
                        } else {
                            self.favoritesManager.likeOffer(with: offer.id)
                        }
                    }
                )
                return viewModel
            }
            SpecialOffersListInteractor.logger.info("create viewModels (amount \(viewModels.count))")
            completion(viewModels)
        }
        
        
    }
}

extension SpecialOffersListInteractor: IFavoritesDelegate {
    func favoritesDidChanged() {
        // --TODO--
    }
}

fileprivate extension SpecialOffersListInteractor {
    func getViewModels(offers: [OfferShortInfo], userInfo: UserInfo, bundles: [SpecialBundle]) -> [SpecialOfferViewModel] {
        []
    }
}
