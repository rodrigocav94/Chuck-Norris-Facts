//
//  ContentModel.swift
//  Chuck Norris Facts
//
//  Created by Rodrigo Cavalcanti on 05/06/21.
//

import SwiftUI

class ChuckModel: ObservableObject {
    // 1. CONFIGURAÇÕES DA BUSCA DA BARRA //
    
    // 1.1. ViewModel da barra de busca
    @Published var isSearching = false
    @Published var searchString = ""
    
    // 1.2. Método para buscar
    func search() {
        searchedFacts.result = []
        isSearching = true
        // 1.2. Etapa 1: definir o URL e codificar espaços
        guard let url = URL(string: "https://api.chucknorris.io/jokes/search?query=\(searchString)".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!) else {
            print("URL Inválido")
            showingAlert = true
            alertTitle = "Error".uppercased()
            alertMessage = "Invalid URL"
            return
        }
        // 1.2. Etapa 2: transferir o URL para um URLRequest
        let request = URLRequest(url: url)
        
        // 1.2. Etapa 3: criar e começar uma tarefa de a partir do URL request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // 1.2. Etapa 4 - Sucesso: Utilizar o resultado da tarefa
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(AllFacts.self, from: data) {
                    // 1.2. Etapa 4 parte 1: Levar para o main thread
                    DispatchQueue.main.async {
                        if decodedResponse.total == 0 {
                            self.showingAlert = true
                            self.alertTitle = "No result".uppercased()
                            self.alertMessage = "Try something different"
                        }
                        // 1.2. Etapa 4 parte 2: Atualizar a UI
                        self.searchedFacts = decodedResponse
                    }
                    // 1.2. Etapa 4 parte 3: Retornar se tudo der certo
                    return
                }
            }
            
            // 1.2. Etapa 4 - Falha: Gerar um alerta se houver falhado
            print("Nenhum dado recebido: \(error?.localizedDescription ?? "Erro desconhecido")")
            DispatchQueue.main.async {
                self.showingAlert = true
                self.alertTitle = "Fetch failed".uppercased()
                self.alertMessage = "\(error?.localizedDescription ?? "Unknown error")"
            }
        }.resume()
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
    @Published var likedFacts = AllFacts(restore: true)
    
    // 3.3 Ação que verifica se existe um item Fact em um array de Fact
    func isFactPresent(fact: AllFacts.Fact, allFacts: [AllFacts.Fact]) -> Bool {
        allFacts.first(where: { $0.id == fact.id }) != nil
    }
    
    // 3.4 Ação que será executada quando o usuário deslizar sob um fato para remove-lo da sua lista de favoritos
    func removeItems(at offsets: IndexSet) {
        likedFacts.result.remove(atOffsets: offsets)
    }
}
