//
//  Model.swift
//  GitGlimpse
//
//  Created by Hoda Elnaghy on 10/25/23.
//

import Foundation

struct RepositoryOwnerModel: Codable {
    let id: Int
    let avatarURL: String?
    let login: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case avatarURL = "avatar_url"
        case login
    }
}

struct RepositoriesModel: Codable {
    let id: Int
    let name: String?
    let owner: RepositoryOwnerModel?
    var createdAt: String?
    var language: String?
    var forksCount: Int?
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case owner
        case createdAt = "created_at"
        case language
        case forksCount = "forks_count"
      }
}

struct RepositoryInfoModel: Codable {
    var createdAt: String?
    var language: String?
    var forksCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case language
        case forksCount = "forks_count"
    }
}

