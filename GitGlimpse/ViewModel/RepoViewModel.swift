//
//  ViewModel.swift
//  GitGlimpse
//
//  Created by Hoda Elnaghy on 10/25/23.
//

import Foundation
import Alamofire
import RealmSwift
import UIKit

class RepoViewModel {
    
    // MARK: - Variables
    let repositoryDataInstance = RepositoryData()
    let dateFomatterInstance = GithubDateFormatter()
    let languageColors: [String: UIColor] = [
        "python": UIColor(red: 0.56, green: 0.76, blue: 0.47, alpha: 1.0),
        "javascript": UIColor(red: 0.98, green: 0.60, blue: 0.01, alpha: 1.0),
        "java": UIColor(red: 0.63, green: 0.68, blue: 0.77, alpha: 1.0),
        "ruby": UIColor(red: 0.70, green: 0.20, blue: 0.26, alpha: 1.0),
        "c++": UIColor(red: 0.13, green: 0.35, blue: 0.58, alpha: 1.0),
        "php": UIColor(red: 0.40, green: 0.34, blue: 0.74, alpha: 1.0),
        "swift": UIColor(red: 0.99, green: 0.65, blue: 0.32, alpha: 1.0),
        "": UIColor.clear
    ]
    
    // MARK: - Initializer
    init() {
        if repositoryDataInstance.getRepositoriesFromRealm().isEmpty {
            repositoryDataInstance.getRepositories(url: "https://api.github.com/repositories")
            repositoryDataInstance.tableViewRepoArray = repositoryDataInstance.repoArray 
        } else {
            repositoryDataInstance.repoArray = repositoryDataInstance.getRepositoriesFromRealm()
            repositoryDataInstance.loadMoreData()
            DispatchQueue.main.async {
                self.repositoryDataInstance.stopLoading?()
            }
        }
    }
}

class GithubDateFormatter {
    
    func formatGitHubDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-d'T'HH:mm:ss'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: dateString) {
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.year, .month, .day], from: date, to: now)
            
            if let years = components.year, let months = components.month {
                if years < 1 && months < 6 {
                    let monthFormatter = DateFormatter()
                    monthFormatter.dateFormat = "EEEE, MMM d, yyyy"
                    return monthFormatter.string(from: date)
                } else if years < 1 {
                    return "\(months) month\(months > 1 ? "s" : "") ago"
                } else if months < 1 {
                    return "\(years) year\(years > 1 ? "s" : "") ago"
                } else {
                    return "\(months) month\(months > 1 ? "s" : "") ago, \(years) year\(years > 1 ? "s" : "") ago"
                }
            }
        }
        return dateString
    }
}

class RepositoryData {
    
    let realm = try! Realm()
    var page = 0
    var perPage = 10
    var repoArray: [RepositoriesModel] = []
    var onDataUpdate: (() -> Void)?
    var noInternetAlert: (() -> Void)?
    var noDataAlert: (() -> Void)?
    var startLoading: (() -> Void)?
    var stopLoading: (() -> Void)?
    var tableViewRepoArray : [RepositoriesModel] = []
    
    // Github access token
    let headers: HTTPHeaders = [
        "Authorization": "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"
    ]
    
    func getRepositories(url: String) {
        DispatchQueue.main.async {
            self.startLoading?()
        }
        if APIManager.shared.isOnline() {
            APIManager.shared.request(.get, url, headers: headers) { (result: Result<[RepositoriesModel], Error>) in
                switch result {
                case .success(let repositories):
                    var updatedRepos: [RepositoriesModel] = []
                    let dispatchGroup = DispatchGroup()
                    
                    for repository in repositories {
                        let createdAtURL = "https://api.github.com/repos/\(repository.owner?.login ?? "")/\(repository.name ?? "")"
                        dispatchGroup.enter()
                        
                        self.getDate(url: createdAtURL, repository: repository) { updatedRepo in
                            updatedRepos.append(updatedRepo)
                            dispatchGroup.leave()
                        }
                    }
                    dispatchGroup.notify(queue: .main) { [self] in
                        self.repoArray = updatedRepos
                        self.saveRepositoriesToRealm()
                        self.loadMoreData()
                        self.stopLoading?()
                        self.onDataUpdate?()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.stopLoading?()
                        self.noDataAlert?()
                    }
                    print("Request failed with error: \(error)")
                }
            }
        } else {
            DispatchQueue.main.async {
                self.stopLoading?()
                self.noInternetAlert?()
            }
        }
    }
    
    func getDate(url: String, repository: RepositoriesModel, completion: @escaping (RepositoriesModel) -> Void) {
        APIManager.shared.request(.get, url, headers: headers) { (result: Result<RepositoryInfoModel, Error>) in
            switch result {
            case .success(let repositoryInfo):
                var updatedRepository = repository
                updatedRepository.createdAt = repositoryInfo.createdAt
                updatedRepository.language = repositoryInfo.language
                updatedRepository.forksCount = repositoryInfo.forksCount
                completion(updatedRepository)
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(repository)
            }
        }
    }
    
    func loadMoreData() {
        let startIndex = page * perPage
        var endIndex = startIndex + perPage - 1
        endIndex = min(endIndex, repoArray.count - 1)
        if startIndex > endIndex {
            return
        }
        tableViewRepoArray += repoArray[startIndex...endIndex]
        onDataUpdate?()
    }
    
    func saveRepositoriesToRealm() {
        do {
            try realm.write {
                for repository in repoArray {
                    let repositoryObject = RepositoryObject()
                    repositoryObject.id = repository.id
                    repositoryObject.name = repository.name ?? ""
                    repositoryObject.createdAt = repository.createdAt ?? ""
                    repositoryObject.language = repository.language ?? ""
                    repositoryObject.forksCount = repository.forksCount ?? 0
                    repositoryObject.avatarUrl = repository.owner?.avatarURL
                    repositoryObject.login = repository.owner?.login
                    realm.add(repositoryObject, update: .modified)
                }
            }
        } catch {
            print("Error saving repositories to Realm: \(error)")
        }
    }
    
    func getRepositoriesFromRealm() -> [RepositoriesModel] {
        let realmObjects = realm.objects(RepositoryObject.self)
        var repositories: [RepositoriesModel] = []
        for repositoryObject in realmObjects {
            let ownerModel = RepositoryOwnerModel(id: repositoryObject.id, avatarURL: repositoryObject.avatarUrl, login: repositoryObject.login)
            let repository = RepositoriesModel(
                id: repositoryObject.id,
                name: repositoryObject.name,
                owner: ownerModel,
                createdAt: repositoryObject.createdAt,
                language: repositoryObject.language,
                forksCount: repositoryObject.forksCount
            )
            repositories.append(repository)
        }
        return repositories
    }
}



