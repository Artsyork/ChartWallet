//
//  StepRow.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUICore

struct StepRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            Text(text)
        }
        .font(.caption)
    }
}
