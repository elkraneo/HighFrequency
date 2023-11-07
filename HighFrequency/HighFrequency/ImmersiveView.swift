//
//  ImmersiveView.swift
//  HighFrequency
//
//  Created by Cristian Díaz on 02.11.23.
//

import ComposableArchitecture
import RealityKit
import RealityKitContent
import SwiftUI

struct ImmersiveView: View {
  let store: StoreOf<AppCore>
  @State private var subscriptions: [EventSubscription] = []
  @State private var debouncedTask: Task<Void, Error>?

  var body: some View {
    WithViewStore(self.store, observe: \.inputText) { viewStore in
      RealityView { content in
        if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
          content.add(scene)

          let didAddEntitySubscription = content.subscribe(to: SceneEvents.DidAddEntity.self) {
            event in
            Task {
              await viewStore.send(.didAddEntity(event.entity.id)).finish()
            }
          }
          subscriptions.append(didAddEntitySubscription)

          let sceneUpdateSubscription = content.subscribe(to: SceneEvents.Update.self) {
            event in
            self.debouncedTask?.cancel()
            self.debouncedTask = Task {
              try await Task.sleep(for: .milliseconds(500))
              await viewStore.send(.didUpdate(event.deltaTime)).finish()
            }
          }
          subscriptions.append(sceneUpdateSubscription)
        }
      } update: { content in
        let material = SimpleMaterial(color: .systemPurple, isMetallic: true)
        let entity = ModelEntity(
          mesh: .generateText(
            viewStore.last?.description ?? ".",
            font: .monospacedSystemFont(ofSize: 11, weight: .medium)
          ),
          materials: [material]
        )
        entity.setScale(.random(in: 0.001...0.1), relativeTo: nil)
        entity.setPosition(
          [
            .random(in: -2...2),
            .random(in: 0...3),
            .random(in: -5...0),
          ],
          relativeTo: nil
        )
        entity.setOrientation(
          .init(angle: .random(in: 0...360), axis: .init(x: 0.25, y: 1, z: 0.25)),
          relativeTo: nil
        )
        content.add(entity)
      }
    }
  }
}

#Preview {
  ImmersiveView(
    store: Store(initialState: AppCore.State()) { AppCore() }
  )
  .previewLayout(.sizeThatFits)
}
