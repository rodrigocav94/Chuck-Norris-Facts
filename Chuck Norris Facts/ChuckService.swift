//
//  Moya.swift
//  Chuck Norris Facts
//
//  Created by Rodrigo Cavalcanti on 06/06/21.
//

import SwiftUI
import Moya

enum ChuckService {
    case getCards(keyword: String)
}

extension ChuckService: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.chucknorris.io")!
    }
    
    var path: String {
        switch self {
        case .getCards:
            return "/jokes/search"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCards:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getCards:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        case .getCards(let keyword):
            return .requestParameters(parameters: ["query" : keyword], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
}
