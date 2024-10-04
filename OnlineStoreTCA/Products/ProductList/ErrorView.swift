//
//  ErrorView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text(":(")
                .font(.custom("AmericanTypewriter", size: 50))
            Text("")
            Text(message)
                .font(.custom("AmericanTypewriter", size: 25))
            Button {
                retryAction()
            } label: {
                Text("Retry")
                    .font(.custom("AmericanTypewriter", size: 25))
                    .foregroundColor(.white)
            }
            .frame(width: 100, height: 60)
            .background(.blue)
            .cornerRadius(10)
            .padding()
            
        }
    }
}

#Preview {
    ErrorView(
        message: "Oops, we couldn't fetch product list",
        retryAction: {}
    )
}
