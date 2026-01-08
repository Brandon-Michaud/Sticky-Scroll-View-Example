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
    ///   - onTap: Optional closure to execute when the view is tapped
    ///   - onStickChange: Optional closure to execute when the view sticks or unsticks
    /// - Returns: The sticky view
    func sticky(
        edge: StickyEdge = .topLeading,
        isTappable: Bool = false,
        onTap: (() -> Void)? = nil,
        onStickChange: ((Bool) -> Void)? = nil
    ) -> some View {
        modifier(
            StickyViewModifier(
                edge: edge,
                isTappable: isTappable,
                onTap: onTap,
                onStickChange: onStickChange
            )
        )
    }
}

extension View {
    /// Transforms a view according to the provided Sticky Transformer
    /// - Parameter transformer: The transforming used to transform the view
    /// - Returns: The transformed view
    func stickyTransform(using transformer: StickyTransforming) -> some View {
        return AnyView(transformer.stickyTransform(content: self))
    }
}
