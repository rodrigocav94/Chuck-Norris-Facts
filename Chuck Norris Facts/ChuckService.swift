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
            guard let url = Bundle.main.url(forResource: "searchSample", withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                return Data()
                
            }
            return data
        }
    }
    
    var task: Task {
        switch self {
        case .getCards(let keyword):
            return .requestParameters(parameters: ["query" : keyword], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
}
