//
//  HighFrequencyApp.swift
//  HighFrequency
//
//  Created by Cristian Díaz on 02.11.23.
//

import ComposableArchitecture
import SwiftUI

@main
struct HighFrequencyApp: App {
  let store: StoreOf<AppCore> = Store(initialState: AppCore.State()) { AppCore() }
  private enum CancelID { case text }

  var body: some Scene {
    WindowGroup {
      ContentView(store: store)
    }
    .windowResizability(.contentMinSize)
    .defaultSize(width: 250, height: 500)

    ImmersiveSpace(id: "ImmersiveSpace") {
      ImmersiveView(store: store)
    }
  }
}

struct AppCore: Reducer {
  struct State: Equatable {
    var entities: [UInt64] = []
    var inputText = ""
    var updateInterval: TimeInterval?
  }

  enum Action: Equatable {
    case didAddEntity(UInt64)
    case didUpdate(TimeInterval)
    case inputTextChanged(String)
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAddEntity(let id):
          state.entities.append(id)
          return .none

        case .didUpdate(let interval):
          state.updateInterval = interval
          return .none

        case .inputTextChanged(let text):
          state.inputText = text
          return .none
      }
    }
  }
}
