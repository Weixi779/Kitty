//
//  KittyApp.swift
//  Kitty
//
//  Created by 孙世伟 on 2025/8/12.
//

import SwiftUI
import ComposableArchitecture

@main
struct KittyApp: App {
    private let store = Store(initialState: JsonToolReducer.State()) {
        JsonToolReducer()
            .dependency(\.jsonTransformUseCase, DefaultJsonTransformUseCase())
    }

    var body: some Scene {
        WindowGroup {
            JsonToolView(store: store)
        }
    }
}
