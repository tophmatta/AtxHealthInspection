//
//  MapButtons.swift
//  AtxHealthInspection
//
//  Created by Toph Matta on 11/11/24.
//

import SwiftUI

struct ClearButton: View {
    @Environment(MapViewModel.self) var viewModel
    
    var body: some View {
        if !viewModel.currentPOIs.isEmpty {
            Button {
                viewModel.clearPOIs()
            } label: {
                Text("Clear")
                    .foregroundStyle(.green)
                    .padding(10)
            }
            .background(
                Capsule()
                    .fill(.surface)
                    .shadow(radius: 5)
            )
        }
    }
}

struct MapActionButton: View {
    let type: ActionButtonType
    let action: () -> ()
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            Image(systemName: type.rawValue)
                .frame(width: 10, height: 10)
                .padding()
                .background(Rectangle().fill(.surface))
                .clipShape(
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: .continuous)
                )
                .foregroundColor(Color.green)
                .padding([.trailing, .bottom])
                .shadow(radius: 5)
        }
    }
}

enum ActionButtonType: String {
    case location = "location.fill"
    case radius = "circle.dotted"
}
