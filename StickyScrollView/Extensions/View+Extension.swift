//
//  View+Extension.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/4/26.
//

import SwiftUI

public extension View {
    /// Makes view sticky within a ``StickyScrollView``
    /// - Parameters:
    ///   - edge: The edge to stick to
    ///   - isTappable: Does tapping scroll to the view
    /// - Returns: The sticky view
    func sticky(edge: StickyEdge = .starting, isTappable: Bool = false) -> some View {
        modifier(StickyViewModifier(edge: edge, isTappable: isTappable))
    }
}
