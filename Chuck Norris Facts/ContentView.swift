//
//  ContentView.swift
//  Chuck Norris Facts
//
//  Created by Rodrigo Cavalcanti on 05/06/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var model = ChuckModel()
    var body: some View {
        
        SearchNavigation(text: $model.searchString, search: model.search, cancel: model.cancel) {
            List {
                ForEach(model.isSearching ? model.searchedFacts.result : model.likedFacts.result) { shockingFact in
                    Card(model: model, shockingFact: shockingFact, liked: model.isFactPresent(fact: shockingFact, allFacts: model.likedFacts.result))
                }
                .onDelete(perform: model.removeItems)
            }
            .navigationBarTitle(Text("Chuck Norris Facts"))
            .alert(isPresented: $model.showingAlert) {
                Alert(title: Text(model.alertTitle), message: Text(model.alertMessage), dismissButton: .default(Text("OK")))
            }
        }.ignoresSafeArea(.all)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
