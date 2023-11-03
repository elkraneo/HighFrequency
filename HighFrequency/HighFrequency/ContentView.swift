//
//  ContentView.swift
//  HighFrequency
//
//  Created by Cristian Díaz on 02.11.23.
//

import ComposableArchitecture
import RealityKit
import RealityKitContent
import SwiftUI

struct ContentView: View {

  @State private var showImmersiveSpace = false
  @State private var immersiveSpaceIsShown = false

  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

  let store: StoreOf<AppCore>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        Model3D(named: "Scene", bundle: realityKitContentBundle)
          .padding(.bottom, 50)

        VStack {
          TextField(
            "...",
            text: viewStore.binding(get: \.inputText, send: { .inputTextChanged($0) })
          )
          .textFieldStyle(.roundedBorder)
          .autocapitalization(.none)
          .disableAutocorrection(true)

          LabeledContent("Entities count", value: "\(viewStore.entities.count)")
            .font(.headline)
            .padding(.horizontal)

          LabeledContent("Delta", value: "\(viewStore.updateInterval?.description ?? "")")
            .font(.headline)
            .padding(.horizontal)

        }
        .padding()

        Toggle("Show Immersive Space", isOn: $showImmersiveSpace)
          .toggleStyle(.button)
          .padding(.top, 50)
      }
      .padding()
      .onChange(of: showImmersiveSpace) { _, newValue in
        Task {
          if newValue {
            switch await openImmersiveSpace(id: "ImmersiveSpace") {
              case .opened:
                immersiveSpaceIsShown = true
              case .error, .userCancelled:
                fallthrough
              @unknown default:
                immersiveSpaceIsShown = false
                showImmersiveSpace = false
            }
          } else if immersiveSpaceIsShown {
            await dismissImmersiveSpace()
            immersiveSpaceIsShown = false
          }
        }
      }
    }
  }
}

#Preview(windowStyle: .automatic) {
  ContentView(
    store: Store(initialState: AppCore.State()) { AppCore() }
  )
}
