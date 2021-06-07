//
//  ContentModel.swift
//  Chuck Norris Facts
//
//  Created by Rodrigo Cavalcanti on 05/06/21.
//

import SwiftUI
import Moya

class ChuckModel: ObservableObject {
    // 1. CONFIGURAÇÕES DA BUSCA DA BARRA //
    
    // 1.1. ViewModel da barra de busca
    @Published var isSearching = false
    @Published var searchString = ""
    
    let chuckProvider: MoyaProvider<ChuckService>
    
    func search(expectation: @escaping (Int) -> Void = {_ in }) {
        searchedFacts.result = []
        isSearching = true
        if self.searchString.count < 3 {
            self.showingAlert = true
            self.alertTitle = "Word is too short".uppercased()
            self.alertMessage = "Try something with 3 to 120 letters"
            return
        }
        chuckProvider.request(.getCards(keyword: searchString)) { result in
            switch result {
            case .success(let response):
                if let decodedResponse = try? JSONDecoder().decode(AllFacts.self, from: response.data) {
                    self.searchedFacts = decodedResponse
                    
                    if decodedResponse.total == 0 {
                        self.showingAlert = true
                        self.alertTitle = "No result".uppercased()
                        self.alertMessage = "Try something different"
                    }
                    expectation(self.searchedFacts.total)
                }
            case .failure(let error):
                print("Nenhum dado recebido: \(error.localizedDescription)")
                self.showingAlert = true
                self.alertTitle = "Fetch failed".uppercased()
                self.alertMessage = "\(error.localizedDescription)"
            }
        }
    }
    
    
    
    // 1.3. Método cancelar busca
    func cancel() {
        isSearching = false
    }
    
    
    
    // 2. CONFIGURAÇÕES DO ALERTA DE ERRO //
    @Published var showingAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    
    
    // 3. CONFIGURAÇÃO DOS FACTS //
    
    //3.1 Definição dos facts
    struct AllFacts: Codable {
        struct Fact: Codable, Identifiable {
            var categories: [String]
            var id: String
            var value: String
            var url: URL
        }
        var total: Int {
            result.count
        }
        var result = [Fact]()
        
        // 3.1.1 Transforma result em JSON e o armazena como valor padrão
        func storeResult() {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(result) {
                UserDefaults.standard.set(encoded, forKey: "result")
            }
        }
        // 3.1.2 Restaura result a partir de um JSON armazenado como valor padrão
        mutating func restoreResults() {
            if let storedLikedFacts = UserDefaults.standard.data(forKey: "result") {
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode([AllFacts.Fact].self, from: storedLikedFacts) {
                    self.result = decoded
                    return
                }
            }
        }
        init(restore: Bool = false) {
            if restore {
                restoreResults()
            }
        }
    }
    //3.2 ViewModel dos facts
    @Published var searchedFacts = AllFacts()
    @Published var likedFacts = AllFacts(restore: true) {
        didSet {
            likedFacts.storeResult()
        }
    }
    
    // 3.3 Ação que verifica se existe um item Fact em um array de Fact
    func isFactPresent(fact: AllFacts.Fact, allFacts: [AllFacts.Fact]) -> Bool {
        allFacts.first(where: { $0.id == fact.id }) != nil
    }
    
    // 3.4 Ação que será executada quando o usuário deslizar sob um fato para remove-lo da sua lista de favoritos
    func removeItems(at offsets: IndexSet) {
        likedFacts.result.remove(atOffsets: offsets)
    }
    init(stubbing: Bool = false) {
        if stubbing {
            chuckProvider = MoyaProvider<ChuckService>(stubClosure: MoyaProvider.immediatelyStub)
        } else {
            chuckProvider = MoyaProvider<ChuckService>()
        }
    }
}
