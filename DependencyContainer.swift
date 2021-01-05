//
//  DependencyContainer.swift
//  Marvel-client
//
//  Created by Pablo Ezequiel Romero Giovannoni on 05/01/2021.
//

import Foundation

class DependencyContainer {
    static let baseURL = URL(string: "https://gateway.marvel.com/v1/public")!

    lazy var apiService: APIServiceProtocol = {
        return APIService(baseURL: Self.baseURL)
    }()

    let coreDataWrapper: CoreDataWrapperProtocol

//    lazy var dataManager: DataManagerProvider = {
//        return DataManagerProvider(context: self)
//    }()

    init() {
        let coreDataWrapperProvider = CoreDataWrapperProvider(containerName: "Data", modelName: "Model", inMemoryContainer: false)
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

//protocol HasDataManager {
//    var dataManager: DataManagerProvider {get}
//}
//
//extension DependencyContainer: HasDataManager { }
