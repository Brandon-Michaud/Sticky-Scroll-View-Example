//
//  ContentView.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 12/31/25.
//

import SwiftUI

struct ContentView: View {
    @State private var shouldShowSheet: Bool = false
    @State private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                // We need to redraw entire scroll view when axis changes to avoid multidirectional scroll
                switch settingsViewModel.scrollAxis {
                case .horizontal:
                    StickyScrollView(axis: settingsViewModel.scrollAxis, behavior: settingsViewModel.stickyBehavior) {
                        HorizontalScrollContentView(
                            shouldStick: settingsViewModel.shouldStick,
                            numHeaders: settingsViewModel.numHeaders,
                            numFooters: settingsViewModel.numFooters,
                            isTappable: settingsViewModel.isTappable
                        )
                    }
                case .vertical:
                    StickyScrollView(axis: settingsViewModel.scrollAxis, behavior: settingsViewModel.stickyBehavior) {
                        VerticalScrollContentView(
                            shouldStick: settingsViewModel.shouldStick,
                            numHeaders: settingsViewModel.numHeaders,
                            numFooters: settingsViewModel.numFooters,
                            isTappable: settingsViewModel.isTappable
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

struct HorizontalScrollContentView: View {
    let shouldStick: Bool
    let numHeaders: Int
    let numFooters: Int
    let isTappable: Bool
    
    var body: some View {
        HStack {
            Text("🔥")
                .font(.title)
                .padding()
            
            ForEach(1..<(numHeaders+1), id: \.self) { idx in
                if shouldStick {
                    Text("🏒 \(idx)")
                        .font(.headline)
                        .frame(maxHeight: .infinity)
                        .padding(5)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .sticky(edge: .starting, isTappable: isTappable)
                } else {
                    Text("🏒 \(idx)")
                        .font(.headline)
                        .frame(maxHeight: .infinity)
                        .padding(5)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Text("Blah blah blah")
            }
            
            ForEach(1..<(numFooters+1), id: \.self) { idx in
                if shouldStick {
                    Text("🥍 \(idx)")
                        .font(.headline)
                        .frame(maxHeight: .infinity)
                        .padding(5)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .sticky(edge: .ending, isTappable: isTappable)
                } else {
                    Text("🥍 \(idx)")
                        .font(.headline)
                        .frame(maxHeight: .infinity)
                        .padding(5)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Text("Yap yap yap")
            }
        }
        .frame(height: 200)
    }
}

struct VerticalScrollContentView: View {
    let shouldStick: Bool
    let numHeaders: Int
    let numFooters: Int
    let isTappable: Bool
    
    var body: some View {
        VStack {
            Text("by Brandon Michaud 🔥")
                .font(.title2)
                .padding()
            
            ForEach(1..<(numHeaders+1), id: \.self) { idx in
                if shouldStick {
                    Text("Header \(idx)")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .sticky(edge: .starting, isTappable: isTappable)
                } else {
                    Text("Header \(idx)")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce ut turpis tempor, porta diam ut, iaculis leo. Phasellus condimentum euismod enim fringilla vulputate. Suspendisse sed quam mattis, suscipit ipsum vel, volutpat quam. Donec sagittis felis nec nulla viverra, et interdum enim sagittis. Nunc egestas scelerisque enim ac feugiat. ")
                    .padding()
            }
            
            ForEach(1..<(numFooters+1), id: \.self) { idx in
                if shouldStick {
                    Text("Footer \(idx)")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .sticky(edge: .ending, isTappable: isTappable)
                } else {
                    Text("Footer \(idx)")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce ut turpis tempor, porta diam ut, iaculis leo. Phasellus condimentum euismod enim fringilla vulputate. Suspendisse sed quam mattis, suscipit ipsum vel, volutpat quam. Donec sagittis felis nec nulla viverra, et interdum enim sagittis. Nunc egestas scelerisque enim ac feugiat. ")
                    .padding()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
