//
//  CardView.swift
//  Chuck Norris Facts
//
//  Created by Rodrigo Cavalcanti on 05/06/21.
//

import SwiftUI

struct Card: View {
    var model: ChuckModel
    @State var shockingFact: ChuckModel.AllFacts.Fact
    @State var liked = false {
        didSet { tapHeart() }
    }
    @State var heartButtonSize: CGFloat = 1
    @State var shareButtonSize: CGFloat = 1
    
    var body: some View {
        VStack(alignment:.leading) {
            Text(shockingFact.value)
                // tamanho da fonte mudará de acordo com a quantidade de caracteres
                .font(shockingFact.value.count > 80 ? .subheadline : .title3)
                .fontWeight(.bold)
                .layoutPriority(1)
            
            HStack {
                if shockingFact.categories.isEmpty {
                    Text("uncategorized".uppercased())
                        .foregroundColor(.white)
                        .bold()
                        .padding(.horizontal)
                        .background((Capsule().foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)))
                } else {
                    ForEach(0..<shockingFact.categories.count) { category in
                        Text(shockingFact.categories[category].uppercased())
                            .foregroundColor(.white)
                            .bold()
                            .padding(.horizontal)
                            .background((Capsule().foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)))
                    }
                }
                Spacer()
                Image(systemName: liked ? "heart.fill" : "heart")
                    .foregroundColor(liked ? .red : .secondary)
                    .font(.system(size: 20, weight: .semibold))
                    .scaleEffect(heartButtonSize)
                    .onTapGesture(perform: { liked.toggle() })
                    .padding(.horizontal)
                
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20, weight: .semibold))
                    .scaleEffect(shareButtonSize)
                    .onTapGesture(perform: {
                        withAnimation(.default.repeatCount(2, autoreverses: true)) {
                            shareButtonSize = 1.4
                        }
                        shareButtonSize = 1
                        shareSheet()
                    })
            }
            .padding(.vertical)
        }
    }
    
    func shareSheet() {
        let activityVC = UIActivityViewController(activityItems: [shockingFact.url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    func tapHeart() {
        if liked {
            // Adiciona o fato à lista de favoritos e anima o botão
            if model.likedFacts.result.firstIndex(where: {$0.id == shockingFact.id}) == nil {
                model.likedFacts.result.append(shockingFact)
                
                withAnimation(.default.repeatCount(2, autoreverses: true)) {
                    heartButtonSize = 1.4
                }
                heartButtonSize = 1
            }

        } else {
            // Remove o fato da lista de favoritos
            if let index = model.likedFacts.result.firstIndex(where: {$0.id == shockingFact.id}) {
                model.likedFacts.result.remove(at: index)
            } else {
                print("O item que precisa ser removido não foi encontrado")
                model.showingAlert = true
                model.alertTitle = "Error".uppercased()
                model.alertMessage = "The item supposed to be removed wasn't found"
            }
        }
    }
}
