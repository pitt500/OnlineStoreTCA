//
//  AmiiboCell.swift
//  AmiiboTCA
//
//  Created by Pedro Rojas on 02/06/22.
//

import SwiftUI

struct AmiiboCell: View {
    var body: some View {
        HStack {
            Image("koopa")
                .resizable()
                .aspectRatio(contentMode: .fit)
                
            
            VStack(alignment: .leading) {
                Text("Koopa")
                    .font(.largeTitle)
                Text("Mario Series")
                    .font(.caption)
            }
        }
        .frame(height: 100)
    }
}

struct AmiiboCell_Previews: PreviewProvider {
    static var previews: some View {
        AmiiboCell()
            .previewLayout(.fixed(width: 300, height: 180))
            
    }
}
