//
//  ViewModel.swift
//  GitGlimpse
//
//  Created by Hoda Elnaghy on 10/25/23.
//

import Foundation
import Alamofire
import RealmSwift

class RepoViewModel {
    
    // MARK: - Variables
    let repositoryDataInstance = RepositoryData()
    let dateFomatterInstance = GithubDateFormatter()
    let languageColors: [String: UIColor] = [
        "Python": UIColor(red: 0.56, green: 0.76, blue: 0.47, alpha: 1.0),
        "JavaScript": UIColor(red: 0.98, green: 0.60, blue: 0.01, alpha: 1.0),
        "Java": UIColor(red: 0.63, green: 0.68, blue: 0.77, alpha: 1.0),
        "Ruby": UIColor(red: 0.70, green: 0.20, blue: 0.26, alpha: 1.0),
        "C++": UIColor(red: 0.13, green: 0.35, blue: 0.58, alpha: 1.0), // #F34B7D
        "PHP": UIColor(red: 0.40, green: 0.34, blue: 0.74, alpha: 1.0),
        "Swift": UIColor(red: 0.99, green: 0.65, blue: 0.32, alpha: 1.0),
        "": UIColor.clear
    ]
    
    // MARK: - Initializer
    init() {
        if repositoryDataInstance.getRepositoriesFromRealm().isEmpty {
            repositoryDataInstance.getRepositories(url: "https://api.github.com/repositories")
        repositoryDataInstance.tableViewRepoArray = repositoryDataInstance.repoArray
        }
        else { repositoryDataInstance.repoArray = repositoryDataInstance.getRepositoriesFromRealm()
            repositoryDataInstance.loadMoreData()
            DispatchQueue.main.async {
                (self.repositoryDataInstance.stopLoading?())
            }
            print(repositoryDataInstance.repoArray?.count)
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
                }
                else {
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
    var per_page = 10
    var repoArray: [RepositoriesModel]?
    var onDataUpdate: (() -> Void)?
    var noInternetAlert: (() -> Void)?
    var noDataAlert: (() -> Void)?
    var startLoading: (() -> Void)?
    var stopLoading: (() -> Void)?
    var tableViewRepoArray : [RepositoriesModel]?

    // My github access token
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
        }
        else {
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.stopLoading?()
                    self.noInternetAlert?()
                }
            }
        }
    }
    
    func getDate(url: String, repository: RepositoriesModel, completion: @escaping (RepositoriesModel) -> Void) {
        APIManager.shared.request(.get, url, headers: headers) { (result: Result<RepositoryInfoModel, Error>) in
            switch result {
            case .success(let repositoryInfo):
                var updatedRepository = repository
                updatedRepository.created_at = repositoryInfo.created_at
                updatedRepository.language = repositoryInfo.language
                updatedRepository.forks_count = repositoryInfo.forks_count
                completion(updatedRepository)
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(repository)
            }
        }
    }

    func loadMoreData() {
        
        let startIndex = page * per_page
        let endIndex = startIndex + per_page - 1
        if endIndex < repoArray?.count ?? 0 {
                if tableViewRepoArray == nil {
                    tableViewRepoArray = []
                }
                tableViewRepoArray?.append(contentsOf: Array(repoArray?[startIndex...endIndex] ?? []))
                onDataUpdate?()
        }
    }

    func saveRepositoriesToRealm() {
        do {
            try realm.write {
                for repository in repoArray ?? [] {
                    let repositoryObject = RepositoryObject()
                    repositoryObject.id = repository.id ?? 0
                    repositoryObject.name = repository.name ?? ""
                    repositoryObject.created_at = repository.created_at ?? ""
                    repositoryObject.language = repository.language ?? ""
                    repositoryObject.forks_count = repository.forks_count ?? 0
                    repositoryObject.avatar_url = repository.owner?.avatar_url
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
            var owner: RepositoryOwnerModel?
            let ownerModel = RepositoryOwnerModel(id: nil, avatar_url: repositoryObject.avatar_url, login: repositoryObject.login)
            let repository = RepositoriesModel(
                id: repositoryObject.id,
                name: repositoryObject.name,
                owner: ownerModel,
                created_at: repositoryObject.created_at,
                language: repositoryObject.language,
                forks_count: repositoryObject.forks_count
            )
            repositories.append(repository)
        }
        return repositories
    }
    
}



