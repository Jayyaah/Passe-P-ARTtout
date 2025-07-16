//
//  PouchView.swift
//  CoreDataArtattack
//
//  Created by Apprenant 10 on 24/03/2023.
//

import SwiftUI

struct PouchView: View {
    
    var artCategory = ["Architecture","Spectacle","Musique", "Sculpture", "Littérature", "Art Visuel"]
    
    var body: some View {
        
    
    
        GeometryReader { geometry in
            ScrollView {
                
                ForEach(artCategory, id: \.self) { category in
                    DividerTitleComponent(title: category, offsetNegatif: -230, offsetPositif: 230)
                    LazyHStack(spacing: -82) {
                        
                        
                        ForEach(0..<3) { component in
                            
                            PouchComponents()
                                .scaledToFit()
                            
                        }
                        
                    }
                    .frame(minWidth: 170, minHeight: 170)
                    }
                }
            
            }
                        .navigationTitle("Magot")
    
    }
}

struct PouchView_Previews: PreviewProvider {
    static var previews: some View {
        PouchView()
    }
}
