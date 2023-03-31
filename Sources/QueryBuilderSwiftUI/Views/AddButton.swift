//
//  AddButton.swift
//  QueryBuilder
//
//  Created by Shyam Kumar on 3/29/23.
//

import SwiftUI

struct AddButton: View {
    var title: String
    var action: () -> Void
    var body: some View {
        Button(
            action: action,
            label: {
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
            }
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.blue)
        }
    }
}

struct AddButton_Previews: PreviewProvider {
    static var previews: some View {
        AddButton(title: "Add condition") {}
    }
}
