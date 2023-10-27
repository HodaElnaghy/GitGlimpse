//
//  Model.swift
//  GitGlimpse
//
//  Created by Hoda Elnaghy on 10/25/23.
//

import Foundation

struct RepositoryOwnerModel: Codable {
    let id: Int?
    let avatar_url: String?
    let login: String?
}

struct RepositoriesModel: Codable {
    let id: Int?
    let name: String?
    let owner: RepositoryOwnerModel?
    var created_at: String?
    var language: String?
    var forks_count: Int?
}

struct RepositoryInfoModel: Codable {
    var created_at: String?
    var language: String?
    var forks_count: Int?
}
