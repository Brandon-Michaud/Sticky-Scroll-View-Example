//
//  StickyScrollView.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/1/26.
//  Adapted from https://github.com/objcio/S01E334-sticky-headers-for-scroll-views-part-2
//

import SwiftUI

/// A ``ScrollView`` that allows content to stick once it reaches the edge of the screen
public struct StickyScrollView<Content: View>: View {
    private let axis: Axis
    private let behavior: StickyBehavior
    private let edgesIgnoringSafeArea: [StickyEdge]
    private let content: Content
    
    @State private var frames: StickyFrames.Value = [:]
    @State private var scrollCoordinator = StickyScrollCoordinator()
    
    /// Creates a ``ScrollView`` that allows content to stick once it reaches the starting edge
    /// - Parameters:
    ///   - axis: The direction of scroll
    ///   - behavior: How to handle when multiple views have reached the starting edge
    ///   - edgesIgnoringSafeArea: The edges which sticky views can enter
    ///   - content: Content of the scroll view
    public init(
        axis: Axis = .vertical,
        behavior: StickyBehavior = .replace,
        edgesIgnoringSafeArea: [StickyEdge] = [],
        @ViewBuilder content: () -> Content
    ) {
        self.axis = axis
        self.behavior = behavior
        self.edgesIgnoringSafeArea = edgesIgnoringSafeArea
        self.content = content()
    }
    
    public var body: some View {
        ScrollView(axis == .horizontal ? .horizontal : .vertical) {
            content
        }
        .onScrollGeometryChange(for: CGPoint.self, of: { $0.contentOffset }) {
            scrollCoordinator.scrollContentOffset = $1
        }
        .onScrollGeometryChange(for: EdgeInsets.self, of: { $0.contentInsets }) {
            scrollCoordinator.scrollContentInsets = $1
        }
        .onScrollGeometryChange(for: CGSize.self, of: { $0.containerSize }) {
            scrollCoordinator.scrollContainerSize = $1
        }
        .scrollPosition($scrollCoordinator.scrollPosition)
        .coordinateSpace(name: scrollCoordinator.coordinateSpace)  // Define coordinate space for subviews
        .onPreferenceChange(StickyFramePreference.self) {
            frames = $0  // Collect individual frames from subviews
        }
        .environment(\.isStickable, true)  // Allow subviews to stick
        .environment(\.stickyAxis, axis)  // Communicate scroll axis to subviews
        .environment(\.stickyBehavior, behavior)  // Communicate sticky behvior to subviews
        .environment(\.stickyEdgesIgnoringSafeArea, edgesIgnoringSafeArea)  // Communicate safe area behvior to subviews
        .environment(\.stickyFrames, frames)  // Communicate frames to subviews
        .environment(\.stickyScrollCoordinator, scrollCoordinator)  // Allow subviews to control scrolling
    }
}

#Preview {
    VStack {
        Color.blue
            .frame(height: 100)
        
        StickyScrollView(axis: .vertical, behavior: .stack) {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .padding()
                ForEach(0..<50) { idx in
                    Text("Heading 1-\(idx)")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .background(.regularMaterial)
                        .sticky(edge: .ending, isTappable: true)
                    Text("Heading 2-\(idx)")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .background(.regularMaterial)
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce ut turpis tempor, porta diam ut, iaculis leo. Phasellus condimentum euismod enim fringilla vulputate. Suspendisse sed quam mattis, suscipit ipsum vel, volutpat quam. Donec sagittis felis nec nulla viverra, et interdum enim sagittis. Nunc egestas scelerisque enim ac feugiat. ")
                        .padding()
                }
            }
            .background(.orange)
        }
        
        Color.blue
            .frame(height: 100)
    }
}

#Preview {
    StickyScrollView(axis: .horizontal, behavior: .replace) {
        HStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .padding()
            ForEach(0..<50) { idx in
                Text("Sticky 1-\(idx)")
                    .font(.headline)
                    .frame(maxHeight: .infinity)
                    .background(.regularMaterial)
                    .sticky(edge: .ending, isTappable: true)
                Text("Sticky 2-\(idx)")
                    .font(.subheadline)
                    .frame(maxHeight: .infinity)
                    .background(.regularMaterial)
                Text("Blah blah blah")
            }
        }
        .frame(height: 200)
        .background(.orange)
    }
    .clipped()
}

#Preview {
    ExampleView()
}
