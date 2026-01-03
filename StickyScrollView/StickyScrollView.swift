//
//  StickyScrollView.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 1/1/26.
//  Adapted from https://github.com/objcio/S01E334-sticky-headers-for-scroll-views-part-2
//

import SwiftUI

/// Controls whether the ``Sticky`` view modifier can be applied
fileprivate enum Stickable: EnvironmentKey {
    fileprivate static var defaultValue: Bool = false
}

/// A preference used by subviews to communicate their frames to their ``StickyScrollView`` superview
fileprivate enum StickyFramePreference: PreferenceKey {
    fileprivate static var defaultValue: [Namespace.ID: StickyFrame] = [:]

    fileprivate static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}

/// The sticky axis used by subviews in a ``StickyScrollView`` to determine their offset
fileprivate enum StickyAxis: EnvironmentKey {
    fileprivate static var defaultValue: Axis = .vertical
}

/// The edge whichy a view should stick to
public enum StickyEdge: CaseIterable {
    /// The top (vertical scroll) or leading (horizontal scroll) edge
    case starting
    
    /// The bottom (vertical scroll) or trailing (horizontal scroll) edge
    case ending
}

/// Describes how a ``StickyScrollView`` should handle situations where multiple subviews are sticking
public enum StickyBehavior: String, CaseIterable {
    /// Any sticky view that reaches the ending edge of an already sticking view
    /// (or the starting edge of the scroll view if no views are sticking)
    /// will replace the already sticking view if there is one
    case replace
    
    /// Any sticky view that reaches the ending edge of already sticking views
    /// (or the starting edge of the scroll view if no views are sticking)
    /// will append to the already sticking views
    case stack
}

/// The ``StickyBehavior`` used by subviews in a ``StickyScrollView`` to determine their offset
fileprivate enum StickyBehaviorKey: EnvironmentKey {
    fileprivate static var defaultValue: StickyBehavior = .stack
}

/// The ``StickyEdge``s that can enter the safe area of a ``StickyScrollView``
fileprivate enum StickyEdgesIgnoringSafeArea: EnvironmentKey {
    fileprivate static var defaultValue: [StickyEdge] = []
}

/// Data representation of a sticky frame and the edge it sticks to
fileprivate struct StickyFrame: Equatable {
    fileprivate let frame: CGRect
    fileprivate let edge: StickyEdge
}

/// A collection of sticky frames used for subviews in a ``StickyScrollView`` to determine their offset
fileprivate enum StickyFrames: EnvironmentKey {
    fileprivate static var defaultValue: [Namespace.ID: StickyFrame] = [:]
}

/// An object that can control the scroll position of a ``StickyScrollView``
@Observable fileprivate final class StickyScrollViewCoordinator {
    /// The coordinate space name used by the sticky scroll view
    fileprivate let coordinateSpace: String
    
    /// The sticky scroll view scroll position
    fileprivate var scrollPosition: ScrollPosition
    
    /// The sticky scroll view content offset
    fileprivate var scrollContentOffset: CGPoint
    
    /// The sticky scroll view content insets
    fileprivate var scrollContentInsets: EdgeInsets
    
    /// The sticky scroll view container size
    fileprivate var scrollContainerSize: CGSize

    /// Makes a ``StickyScrollViewCoordinator`` with an initial position
    /// - Parameters:
    ///   - coordinateSpace: The name of the coordinate space for the ``StickyScrollView``
    ///   - scrollPosition: Initial ``ScrollPosition`` of the ``StickyScrollView``
    ///   - scrollContentOffset: Content offset of the ``StickyScrollView``
    ///   - scrollContentInsets: Content insets of the ``StickyScrollView``
    ///   - scrollContainerSize: Container size of the ``StickyScrollView``
    fileprivate init(
        coordinateSpace: String = "stickyCoordinateSpace",
        scrollPosition: ScrollPosition = ScrollPosition(edge: .top),
        scrollContentOffset: CGPoint = .zero,
        scrollContentInsets: EdgeInsets = .init(),
        scrollContainerSize: CGSize = .zero
    ) {
        self.coordinateSpace = coordinateSpace
        self.scrollPosition = scrollPosition
        self.scrollContentOffset = scrollContentOffset
        self.scrollContentInsets = scrollContentInsets
        self.scrollContainerSize = scrollContainerSize
    }
}

/// A ``StickyScrollViewCoordinator`` that subviews of a ``StickyScrollView`` can use to control the scroll position
fileprivate enum StickyScrollCoordinator: EnvironmentKey {
    fileprivate static var defaultValue: StickyScrollViewCoordinator? = nil
}

fileprivate extension EnvironmentValues {
    /// Controls whether the ``Sticky`` view modifier can be applied
    var isStickable: Stickable.Value {
        get { self[Stickable.self] }
        set { self[Stickable.self] = newValue }
    }
    
    /// The sticky axis used by subviews in a ``StickyScrollView`` to determine their offset
    var stickyAxis: StickyAxis.Value {
        get { self[StickyAxis.self] }
        set { self[StickyAxis.self] = newValue }
    }
    
    /// Describes how a ``StickyScrollView`` should handle situations where multiple subviews are sticking
    var stickyBehavior: StickyBehaviorKey.Value {
        get { self[StickyBehaviorKey.self] }
        set { self[StickyBehaviorKey.self] = newValue }
    }
    
    /// The safe area edges which sticky subviews in a ``StickyScrollView`` can enter
    var stickyEdgesIgnoringSafeArea: StickyEdgesIgnoringSafeArea.Value {
        get { self[StickyEdgesIgnoringSafeArea.self] }
        set { self[StickyEdgesIgnoringSafeArea.self] = newValue }
    }
    
    /// A collection of sticky frames used for subviews in a ``StickyScrollView`` to determine their offset
    var stickyFrames: StickyFrames.Value {
        get { self[StickyFrames.self] }
        set { self[StickyFrames.self] = newValue }
    }
    
    /// An optional ``StickyScrollViewCoordinator`` that subviews of a ``StickyScrollView`` can use to control the scroll position
    var stickyScrollCoordinator: StickyScrollCoordinator.Value {
        get { self[StickyScrollCoordinator.self] }
        set { self[StickyScrollCoordinator.self] = newValue }
    }
}

/// A view modifier to make some view inside of a ``StickyScrollView`` sticky
public struct Sticky: ViewModifier {
    @Namespace private var id
    
    // Collect offset rendering information
    @Environment(\.isStickable) fileprivate var isStickable
    @Environment(\.stickyAxis) fileprivate var stickyAxis
    @Environment(\.stickyBehavior) fileprivate var stickyBehavior
    @Environment(\.stickyEdgesIgnoringSafeArea) fileprivate var stickyEdgesIgnoringSafeArea
    @Environment(\.stickyFrames) fileprivate var stickyFrames
    @Environment(\.stickyScrollCoordinator) fileprivate var stickyScrollCoordinator
    
    // Keep track of the view's frame
    @State private var frame: CGRect = .zero
    
    private let edge: StickyEdge
    private let isTappable: Bool
    
    /// Creates a view modifier to make content stick to the starting edge
    /// - Parameters:
    ///   - edge: The edge of the ``StickyScrollView`` the view should stick to
    ///   - isTappable: Whether or not tapping the sticky content scrolls to it
    public init(edge: StickyEdge = .starting, isTappable: Bool = false) {
        self.edge = edge
        self.isTappable = isTappable
    }
    
    /// If the view should be sticking
    private var isSticking: Bool {
        switch edge {
        case .starting:
            switch stickyAxis {
            case .horizontal:
                return frame.minX < stickingThreshold
            case .vertical:
                return frame.minY < stickingThreshold
            }
        case .ending:
            switch stickyAxis {
            case .horizontal:
                return frame.maxX > stickingThreshold
            case .vertical:
                return frame.maxY > stickingThreshold
            }
        }
    }
    
    /// The end position of the scroll view
    private var scrollContainerEnd: CGFloat? {
        guard let stickyScrollCoordinator else { return nil }
        switch stickyAxis {
        case .horizontal:
            return stickyScrollCoordinator.scrollContainerSize.width
        case .vertical:
            return stickyScrollCoordinator.scrollContainerSize.height
        }
    }
    
    /// Gets the correct safe area inset for view
    private var safeAreaInset: CGFloat {
        guard let safeAreaInsets = stickyScrollCoordinator?.scrollContentInsets else { return .zero }
        guard stickyEdgesIgnoringSafeArea.contains(edge) else { return .zero }
        switch edge {
        case .starting:
            switch stickyAxis {
            case .horizontal:
                return safeAreaInsets.leading
            case .vertical:
                return safeAreaInsets.top
            }
        case .ending:
            switch stickyAxis {
            case .horizontal:
                return safeAreaInsets.trailing
            case .vertical:
                return safeAreaInsets.bottom
            }
        }
    }
    
    /// The minimum/maximum value below/above which a view will stick
    private var stickingThreshold: CGFloat {
        // If we do not have the scrollContainerBounds we cannot compute threshold and the view should not stick
        guard let scrollContainerEnd else {
            switch edge {
            case .starting:
                return -.infinity
            case .ending:
                return .infinity
            }
        }
        
        // If we are replacing views, the thresholds are the edges of the scroll view
        guard stickyBehavior != .replace else {
            switch edge {
            case .starting:
                return .zero - safeAreaInset
            case .ending:
                return scrollContainerEnd + safeAreaInset
            }
        }
        
        switch edge {
        case .starting:
            switch stickyAxis {
            case .horizontal:
                // Find cumulative width of other sticky frames to the left of this one
                let otherSticking = stickyFrames.filter { (key, value) in
                    key != id && value.edge == edge && value.frame.minX <= frame.minX
                }
                return -safeAreaInset + otherSticking.reduce(into: 0) { (result, element) in
                    result += element.value.frame.width
                }
            case .vertical:
                // Find cumulative height of other sticky frames above this one
                let otherSticking = stickyFrames.filter { (key, value) in
                    key != id && value.edge == edge && value.frame.minY <= frame.minY
                }
                return -safeAreaInset + otherSticking.reduce(into: 0) { (result, element) in
                    result += element.value.frame.height
                }
            }
        case .ending:
            switch stickyAxis {
            case .horizontal:
                // Find cumulative width of other sticky frames to the right of this one
                let otherSticking = stickyFrames.filter { (key, value) in
                    key != id && value.edge == edge && value.frame.maxX >= frame.maxX
                }
                return scrollContainerEnd + safeAreaInset - otherSticking.reduce(into: 0) { (result, element) in
                    result += element.value.frame.width
                }
            case .vertical:
                // Find cumulative height of other sticky frames below this one
                let otherSticking = stickyFrames.filter { (key, value) in
                    key != id && value.edge == edge && value.frame.maxY >= frame.maxY
                }
                return scrollContainerEnd + safeAreaInset  - otherSticking.reduce(into: 0) { (result, element) in
                    result += element.value.frame.height
                }
            }
        }
    }
    
    /// The offset needed to keep the view visible
    private var offset: CGSize {
        // Do not offset if this view is not yet sticking
        guard isSticking else { return CGSize.zero }
        
        switch stickyBehavior {
        case .replace:
            switch edge {
            case .starting:
                switch stickyAxis {
                case .horizontal:
                    // Offset so view is at the leading edge
                    var offset = stickingThreshold - frame.minX
                    
                    // Find first frame to the right of this view that would collide and
                    // calculate offset to prevent that
                    if let other = stickyFrames.first(where: { (key, value) in
                        key != id && value.edge == edge && value.frame.minX > frame.minX
                            && value.frame.minX - stickingThreshold < frame.width
                    }) {
                        offset -= frame.width + stickingThreshold - other.value.frame.minX
                    }
                    
                    return CGSize(width: offset, height: .zero)
                case .vertical:
                    // Offset so view is at the top edge
                    var offset = stickingThreshold - frame.minY
                    
                    // Find first frame below this view that would collide and
                    // calculate offset to prevent that
                    if let other = stickyFrames.first(where: { (key, value) in
                        key != id && value.edge == edge && value.frame.minY > frame.minY
                            && value.frame.minY - stickingThreshold < frame.height
                    }) {
                        offset -= frame.height + stickingThreshold - other.value.frame.minY
                    }
                    
                    return CGSize(width: .zero, height: offset)
                }
            case .ending:
                switch stickyAxis {
                case .horizontal:
                    // Offset so view is at the trailing edge
                    var offset = stickingThreshold - frame.maxX
                    
                    // Find first frame to the left of this view that would collide and
                    // calculate offset to prevent that
                    // TODO: There is a bug here because every single sticking frame with find the same "other"
                    // TODO: We really need the "other" frame with the maximum minX
                    if let other = stickyFrames.first(where: { (key, value) in
                        key != id && value.edge == edge && value.frame.minX < frame.minX
                            && stickingThreshold - value.frame.maxX < frame.width
                    }) {
                        offset += frame.width - stickingThreshold + other.value.frame.maxX
                    }
                    
                    return CGSize(width: offset, height: .zero)
                case .vertical:
                    // Offset so view is at the bottom edge
                    var offset = stickingThreshold - frame.maxY
                    
                    // Find first frame above this view that would collide and
                    // calculate offset to prevent that
                    // TODO: There is a bug here because every single sticking frame with find the same "other"
                    // TODO: We really need the "other" frame with the maximum minY
                    if let other = stickyFrames.first(where: { (key, value) in
                        key != id && value.edge == edge && value.frame.minY < frame.minY
                            && stickingThreshold - value.frame.maxY < frame.height
                    }) {
                        offset += frame.height - stickingThreshold + other.value.frame.maxY
                    }
                    
                    return CGSize(width: .zero, height: offset)
                }
            }
        case .stack:
            switch edge {
            case .starting:
                switch stickyAxis {
                case .horizontal:
                    // Offset view to the leading/trailing edge of the stack
                    return CGSize(width: -frame.minX + stickingThreshold, height: .zero)
                case .vertical:
                    // Offset view to the top/bottom edge of the stack
                    return CGSize(width: .zero, height: -frame.minY + stickingThreshold)
                }
            case .ending:
                switch stickyAxis {
                case .horizontal:
                    // Offset view to the leading/trailing edge of the stack
                    return CGSize(width: -frame.maxX + stickingThreshold, height: .zero)
                case .vertical:
                    // Offset view to the top/bottom edge of the stack
                    return CGSize(width: .zero, height: -frame.maxY + stickingThreshold)
                }
            }
        }
    }
    
    /// The position to scroll to when the view is tapped
    private var scrollPosition: CGPoint {
        guard
            let scrollContentOffset = stickyScrollCoordinator?.scrollContentOffset,
            let scrollContentInsets = stickyScrollCoordinator?.scrollContentInsets
        else {
            return .zero
        }
        
        switch stickyAxis {
        case .horizontal:
            let startingAnchor = frame.minX + scrollContentOffset.x - stickingThreshold + scrollContentInsets.leading
            let anchorOffset = edge == .ending ? frame.width : .zero
            return CGPoint(x: startingAnchor + anchorOffset, y: .zero)
        case .vertical:
            let startingAnchor = frame.minY + scrollContentOffset.y - stickingThreshold + scrollContentInsets.top
            let anchorOffset = edge == .ending ? frame.height : .zero
            return CGPoint(x: .zero, y: startingAnchor + anchorOffset)
        }
    }

    public func body(content: Content) -> some View {
        if isStickable, let coordinateSpace = stickyScrollCoordinator?.coordinateSpace {
            content
                .id(id)
                .offset(offset)
                .zIndex(isSticking ? .infinity : 0)  // If the view is sticking, it should appear above all others
                .overlay(GeometryReader { geometry in
                    let frame = geometry.frame(in: .named(coordinateSpace))
                    Color.clear
                        .onAppear { self.frame = frame }
                        .onChange(of: frame) { self.frame = frame }
                        .preference(key: StickyFramePreference.self, value: [id: StickyFrame(frame: self.frame, edge: edge)])
                })
                .onTapGesture {
                    if isTappable {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            stickyScrollCoordinator?.scrollPosition.scrollTo(point: scrollPosition)
                        }
                    }
                }
        } else {
            content
        }
    }
}

public extension View {
    /// Makes view sticky within a ``StickyScrollView``
    /// - Parameters:
    ///   - edge: The edge to stick to
    ///   - isTappable: Does tapping scroll to the view
    /// - Returns: The sticky view
    func sticky(edge: StickyEdge = .starting, isTappable: Bool = false) -> some View {
        modifier(Sticky(edge: edge, isTappable: isTappable))
    }
}

/// A ``ScrollView`` that allows content to stick once it reaches the edge of the screen
public struct StickyScrollView<Content: View>: View {
    private let axis: Axis
    private let behavior: StickyBehavior
    private let edgesIgnoringSafeArea: [StickyEdge]
    private let content: Content
    
    @State private var frames: StickyFrames.Value = [:]
    @State private var scrollCoordinator = StickyScrollViewCoordinator()
    
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
    ContentView()
}
