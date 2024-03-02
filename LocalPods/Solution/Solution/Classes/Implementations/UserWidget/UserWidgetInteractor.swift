//
//  UserWidgetInteractor.swift
//  Solution
//
//  Created by Kuznetsov Mikhail on 16.02.2024.
//

import Foundation
import OSLog
import Combine

public protocol IUserWidgetInteractor: AnyObject {
    func prepareConfiguration(userId: String, completion: @escaping (UserViewModel?) -> Void)
}

final class UserWidgetInteractor: IUserWidgetInteractor {

    private let userInfoService: IUserInfoService
    private let operationsService: IOperationsService
    private static let logger = Logger(subsystem: "UserWidgetInteractor", category: "Networking")

    init(userInfoService: IUserInfoService, operationsService: IOperationsService) {
        self.userInfoService = userInfoService
        self.operationsService = operationsService
    }

    func prepareConfiguration(userId: String, completion: @escaping (UserViewModel?) -> Void) {
        let group = DispatchGroup()
        var operations: [Operation]?
        var userInfo: UserInfo?
        var isFirstCallOperationService = true, isFirstCallUserInfoService = true
        
        group.enter()
        operationsService.currentAccount(for: userId) { result in
            if isFirstCallOperationService {
                isFirstCallOperationService = false
            } else {
                return
            }
            operations = result
            group.leave()
            
        }
        group.enter()
        userInfoService.userInfo(for: userId) { result in
            if isFirstCallUserInfoService {
                isFirstCallUserInfoService = false
            } else {
               return
            }
            userInfo = result
            group.leave()
        }
        
        group.notify(queue: .main) {
            guard let operations, let userInfo else {
                UserWidgetInteractor.logger.error(
                    "Not create ViewModel: operations=\(String(describing: operations)); userInfo=\(String(describing: userInfo))"
                )
                completion(nil)
                return
            }
            var money: Double = 0
            var bonus: Double = 0
            for operation in operations {
                switch operation {
                case .receipt(let value, let currency):
                    switch currency {
                    case .specialPoint:
                        bonus += value
                    case .rub:
                        money += value
                    }
                case .withdrawal(let value, let currency):
                    switch currency {
                    case .specialPoint:
                        bonus -= value
                    case .rub:
                        money -= value
                    }
                }
            }
            
            let moneyFormatter = NumberFormatter()
            moneyFormatter.numberStyle = .decimal
            moneyFormatter.groupingSeparator = " "
            moneyFormatter.minimumFractionDigits = 2
            moneyFormatter.maximumFractionDigits = 2
            
            
            let bonusFormatter = NumberFormatter()
            bonusFormatter.numberStyle = .decimal
            bonusFormatter.groupingSeparator = " "
            
            let stringBonus = "\(bonusFormatter.string(for: bonus)!) бал."
            let stringMoney = "\(moneyFormatter.string(for: money)!) ₽"
            
            UserWidgetInteractor.logger.info("create UserViewModel")
            completion(
                UserViewModel(
                    name: userInfo.name,
                    bonusValue: stringBonus,
                    moneyValue: stringMoney
                )
            )
        }
    }
}
