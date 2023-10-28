//
//  RealmModel.swift
//  GitGlimpse
//
//  Created by Hoda Elnaghy on 10/27/23.
//

import Foundation
import RealmSwift

class RepositoryObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var createdAt: String
    @Persisted var language: String
    @Persisted var forksCount: Int
    @Persisted var avatarUrl: String?
    @Persisted var login: String?
}

class RepositoryOwnerObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var avatarUrl: String
    @Persisted var login: String
}
