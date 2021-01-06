//
//  DependencyContainer.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation

class DependencyContainer {
    static let baseURL = URL(string: "https://gateway.marvel.com/v1/public")!
    static let publicKey = "33e8c746925766921345ba5312aceae5"
    static let privateKey = "bac4c8f43c6758d140d9bd98f916fd731849d521"

    lazy var apiService: APIServiceProtocol = {
        let signRequestBehavior = SignRequestBehavior(
            publicKey: Self.publicKey,
            privateKey: Self.privateKey
        )

        return APIService(baseURL: Self.baseURL, behaviors: [signRequestBehavior])
    }()

    lazy var networkStatus: NetworkStatus = {
        return NetworkStatusProvider()
    }()

    let coreDataWrapper: CoreDataWrapperProtocol

    lazy var dataManager: DataManagerProvider = {
        return DataManagerProvider(context: self)
    }()

    init() {
        let coreDataWrapperProvider = CoreDataWrapperProvider(
            containerName: "Data",
            modelName: "Model",
            inMemoryContainer: false
        )

        CoreDataWrapper.shared = coreDataWrapperProvider
        self.coreDataWrapper = coreDataWrapperProvider
    }
}

protocol HasAPIService {
    var apiService: APIServiceProtocol {get}
}

extension DependencyContainer: HasAPIService { }

protocol HasCoreDataWrapper {
    var coreDataWrapper: CoreDataWrapperProtocol {get}
}

extension DependencyContainer: HasCoreDataWrapper { }

protocol HasDataManager {
    var dataManager: DataManagerProvider {get}
}

extension DependencyContainer: HasDataManager { }

protocol HasNetworkStatus {
    var networkStatus: NetworkStatus {get}
}

extension DependencyContainer: HasNetworkStatus { }
