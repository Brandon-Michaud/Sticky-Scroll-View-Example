//
//  StickyEdge.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/4/26.
//

/// The edge whichy a view should stick to
public enum StickyEdge: CaseIterable {
    /// The top (vertical scroll) or leading (horizontal scroll) edge
    case topLeading
    
    /// The bottom (vertical scroll) or trailing (horizontal scroll) edge
    case bottomTrailing
}
