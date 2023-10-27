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
    @Persisted var created_at: String
    @Persisted var language: String
    @Persisted var forks_count: Int
    @Persisted var avatar_url: String?
    @Persisted var login: String?
    var owner = LinkingObjects(fromType: RepositoryOwnerObject.self, property: "repositories")
}

class RepositoryOwnerObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var avatar_url: String
    @Persisted var login: String
    let repositories = List<RepositoryObject>()
}
