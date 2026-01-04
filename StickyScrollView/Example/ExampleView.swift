//
//  ExampleView.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 12/31/25.
//

import SwiftUI

struct ExampleView: View {
    @State fileprivate var shouldShowSheet: Bool = false
    @State fileprivate var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                // We need to redraw entire scroll view when axis changes to avoid multidirectional scroll
                switch settingsViewModel.scrollAxis {
                case .horizontal:
                    StickyScrollView(
                        axis: settingsViewModel.scrollAxis,
                        behavior: settingsViewModel.stickyBehavior,
                        edgesIgnoringSafeArea: settingsViewModel.edgesIgnoringSafeArea
                    ) {
                        HorizontalScrollContentView(
                            shouldStick: settingsViewModel.shouldStick,
                            numHeaders: settingsViewModel.numHeaders,
                            numFooters: settingsViewModel.numFooters,
                            isTappable: settingsViewModel.isTappable,
                            growOnTap: settingsViewModel.growOnTap,
                            invertOnStick: settingsViewModel.invertOnStick
                        )
                    }
                case .vertical:
                    StickyScrollView(
                        axis: settingsViewModel.scrollAxis,
                        behavior: settingsViewModel.stickyBehavior,
                        edgesIgnoringSafeArea: settingsViewModel.edgesIgnoringSafeArea
                    ) {
                        VerticalScrollContentView(
                            shouldStick: settingsViewModel.shouldStick,
                            numHeaders: settingsViewModel.numHeaders,
                            numFooters: settingsViewModel.numFooters,
                            isTappable: settingsViewModel.isTappable,
                            growOnTap: settingsViewModel.growOnTap,
                            invertOnStick: settingsViewModel.invertOnStick
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text("Sticky Scroll View")
                        .font(.title)
                        .bold()
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        shouldShowSheet = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .background {
                LinearGradient(colors: [.purple, .green], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $shouldShowSheet) {
                SettingsView(
                    viewModel: $settingsViewModel
                )
                .presentationDetents([.medium])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

fileprivate struct StickyExampleViewModifier: ViewModifier {
    fileprivate let num: Int
    fileprivate let edge: StickyEdge
    fileprivate let isTappable: Bool
    fileprivate let growOnTap: Bool
    fileprivate let invertOnStick: Bool
    
    @State fileprivate var isPressed: Bool = false
    @State fileprivate var isSticking: Bool = false
    
    fileprivate func body(content: Content) -> some View {
        content
            .modifier(InvertedViewModifier(shouldInvert: invertOnStick && isSticking))
            .scaleEffect(isPressed ? 1.15 : 1.0)
            .sticky(edge: edge, isTappable: isTappable) {
                if growOnTap {
                    let duration = 0.25
                    withAnimation(.easeIn(duration: duration)) {
                        isPressed = true
                    }
                    
                    Task { @MainActor in
                        try await Task.sleep(for: .seconds(duration))
                        withAnimation(.easeOut(duration: duration)) {
                            isPressed = false
                        }
                    }
                }
            } onStickChange: { isSticking in
                self.isSticking = isSticking
            }
    }
}

fileprivate struct InvertedViewModifier: ViewModifier {
    fileprivate let shouldInvert: Bool
    
    fileprivate func body(content: Content) -> some View {
        if shouldInvert {
            content
                .colorInvert()
        } else {
            content
        }
    }
}

fileprivate struct HorizontalScrollContentView: View {
    fileprivate let shouldStick: Bool
    fileprivate let numHeaders: Int
    fileprivate let numFooters: Int
    fileprivate let isTappable: Bool
    fileprivate let growOnTap: Bool
    fileprivate let invertOnStick: Bool
    
    fileprivate var body: some View {
        HStack {
            Text("🔥")
                .font(.title)
                .padding()
            
            ForEach(1..<(numHeaders+1), id: \.self) { idx in
                if shouldStick {
                    Header(num: idx)
                        .modifier(
                            StickyExampleViewModifier(
                                num: idx,
                                edge: .starting,
                                isTappable: isTappable,
                                growOnTap: growOnTap,
                                invertOnStick: invertOnStick
                            )
                        )
                } else {
                    Header(num: idx)
                }
                
                Text("Blah blah blah")
            }
            
            ForEach(1..<(numFooters+1), id: \.self) { idx in
                if shouldStick {
                    Footer(num: idx)
                        .modifier(
                            StickyExampleViewModifier(
                                num: idx,
                                edge: .ending,
                                isTappable: isTappable,
                                growOnTap: growOnTap,
                                invertOnStick: invertOnStick
                            )
                        )
                } else {
                    Footer(num: idx)
                }
                
                Text("Yap yap yap")
            }
        }
        .frame(height: 200)
    }
    
    fileprivate struct Header: View {
        fileprivate let num: Int
        
        fileprivate var body: some View {
            Text("🏒 \(num)")
                .font(.headline)
                .frame(maxHeight: .infinity)
                .padding(5)
                .background(Color(uiColor: .systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    fileprivate struct Footer: View {
        fileprivate let num: Int
        
        fileprivate var body: some View {
            Text("🥍 \(num)")
                .font(.headline)
                .frame(maxHeight: .infinity)
                .padding(5)
                .background(Color(uiColor: .systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

fileprivate struct VerticalScrollContentView: View {
    fileprivate let shouldStick: Bool
    fileprivate let numHeaders: Int
    fileprivate let numFooters: Int
    fileprivate let isTappable: Bool
    fileprivate let growOnTap: Bool
    fileprivate let invertOnStick: Bool
    
    fileprivate var body: some View {
        VStack {
            Text("by Brandon Michaud 🔥")
                .font(.title2)
                .padding()
            
            ForEach(1..<(numHeaders+1), id: \.self) { idx in
                if shouldStick {
                    Header(num: idx)
                        .modifier(
                            StickyExampleViewModifier(
                                num: idx,
                                edge: .starting,
                                isTappable: isTappable,
                                growOnTap: growOnTap,
                                invertOnStick: invertOnStick
                            )
                        )
                } else {
                    Header(num: idx)
                }
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce ut turpis tempor, porta diam ut, iaculis leo. Phasellus condimentum euismod enim fringilla vulputate. Suspendisse sed quam mattis, suscipit ipsum vel, volutpat quam. Donec sagittis felis nec nulla viverra, et interdum enim sagittis. Nunc egestas scelerisque enim ac feugiat. ")
                    .padding()
            }
            
            ForEach(1..<(numFooters+1), id: \.self) { idx in
                if shouldStick {
                    Footer(num: idx)
                        .modifier(
                            StickyExampleViewModifier(
                                num: idx,
                                edge: .ending,
                                isTappable: isTappable,
                                growOnTap: growOnTap,
                                invertOnStick: invertOnStick
                            )
                        )
                } else {
                    Footer(num: idx)
                }
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce ut turpis tempor, porta diam ut, iaculis leo. Phasellus condimentum euismod enim fringilla vulputate. Suspendisse sed quam mattis, suscipit ipsum vel, volutpat quam. Donec sagittis felis nec nulla viverra, et interdum enim sagittis. Nunc egestas scelerisque enim ac feugiat. ")
                    .padding()
            }
        }
        .padding(.horizontal)
    }
    
    fileprivate struct Header: View {
        fileprivate let num: Int
        
        fileprivate var body: some View {
            Text("Header \(num)")
                .font(.title)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    fileprivate struct Footer: View {
        fileprivate let num: Int
        
        fileprivate var body: some View {
            Text("Footer \(num)")
                .font(.title)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    ExampleView()
}
