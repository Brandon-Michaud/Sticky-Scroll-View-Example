//
//  SettingsViewModel.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/3/26.
//

import SwiftUI

@Observable final class SettingsViewModel {
    var shouldStick: Bool = true
    var scrollAxis: Axis = .vertical
    var stickyBehavior: StickyBehavior = .fadeOut
    var numHeaders: Int = 5
    var numFooters: Int = 5
    var isTappable: Bool = true
    var ignoreStartingSafeArea: Bool = false
    var ignoreEndingSafeArea: Bool = false
    var growOnTap: Bool = false
    var invertOnStick: Bool = false
    
    var edgesIgnoringSafeArea: [StickyEdge] {
        var edges: [StickyEdge] = []
        if ignoreStartingSafeArea {
            edges.append(.topLeading)
        }
        if ignoreEndingSafeArea {
            edges.append(.bottomTrailing)
        }
        return edges
    }
}
