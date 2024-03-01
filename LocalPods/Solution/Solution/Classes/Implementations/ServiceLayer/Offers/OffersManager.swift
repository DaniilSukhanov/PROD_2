//
//  OffersManager.swift
//  Solution
//
//  Created by Kuznetsov Mikhail on 14.02.2024.
//

import Foundation

public protocol IOffersManager {
    func filter(
        offers: [OfferShortInfo],
        for bundle: SpecialBundle?
    ) -> [OfferShortInfo]
}

final class OffersManager: IOffersManager {

    func filter(
        offers: [OfferShortInfo],
        for bundle: SpecialBundle?
    ) -> [OfferShortInfo] {
        guard let bundle else {
            return offers
        }
        return offers.filter { offer in
            for restriction in offer.restrictions {
                switch restriction {
                case .forBundles(let bundlesIds, let newValue):
                    if !bundlesIds.contains(bundle.code) {
                        return false
                    }
                }
            }
            if offer.type == "HIDDEN" {
                return false
            }
            
            if offer.type == "CREDIT" && (offer.status == "NEW" || offer.status == "OLD") {
                return true
            }
            
            if offer.type == "PERSONAL" {
                return offer.restrictions.isEmpty
            }
            return false
        }
    }
}
