//
//  ContentView.swift
//  StickyScrollView
//
//  Created by Brandon Michaud on 12/31/25.
//

import SwiftUI

struct ContentView: View {
    @State private var shouldShowSheet: Bool = false
    @State private var shouldStick: Bool = true
    @State private var scrollAxis: Axis = .vertical
    @State private var stickyBehavior: StickyBehavior = .replace
    @State private var isTappable: Bool = false
    
    var body: some View {
        NavigationView {
            Group {
                // We need to redraw entire scroll view when axis changes to avoid multidirectional scroll
                switch scrollAxis {
                case .horizontal:
                    StickyScrollView(axis: scrollAxis, behavior: stickyBehavior) {
                        HorizontalScrollContentView(shouldStick: shouldStick, isTappable: isTappable)
                    }
                case .vertical:
                    StickyScrollView(axis: scrollAxis, behavior: stickyBehavior) {
                        VerticalScrollContentView(shouldStick: shouldStick, isTappable: isTappable)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
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
                SettingsSheetView(
                    shouldStick: $shouldStick,
                    scrollAxis: $scrollAxis,
                    stickyBehavior: $stickyBehavior,
                    isTappable: $isTappable
                )
                .presentationDetents([.medium])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
    }
}

struct SettingsSheetView: View {
    @Binding var shouldStick: Bool
    @Binding var scrollAxis: Axis
    @Binding var stickyBehavior: StickyBehavior
    @Binding var isTappable: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title2)
            
            Toggle("Should Stick", isOn: $shouldStick)
                .font(.headline)
            
            VStack(alignment: .leading) {
                Text("Scroll Axis")
                    .font(.headline)
                
                Picker("Scroll Axis", selection: $scrollAxis) {
                    ForEach(Array(Axis.allCases), id: \.self) { axis in
                        Text(axis.description.capitalized)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading) {
                Text("Sticky Behavior")
                    .font(.headline)
                
                Picker("Sticky Behavior", selection: $stickyBehavior) {
                    ForEach(Array(StickyBehavior.allCases), id: \.self) { behavior in
                        Text(behavior.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Toggle("Is Tappable", isOn: $isTappable)
                .font(.headline)
            
            Spacer()
        }

    }
}

struct HorizontalScrollContentView: View {
    let shouldStick: Bool
    let isTappable: Bool
    
    var body: some View {
        HStack {
            Text("🔥")
                .font(.title)
                .padding()
            ForEach(1..<51) { idx in
                if shouldStick {
                    Text("🏒 \(idx)")
                        .font(.headline)
                        .frame(maxHeight: .infinity)
                        .padding(5)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .sticky(isTappable: isTappable)
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
        }
        .frame(height: 200)
    }
}

struct VerticalScrollContentView: View {
    let shouldStick: Bool
    let isTappable: Bool
    
    var body: some View {
        VStack {
            Text("by Brandon Michaud 🔥")
                .font(.title2)
                .padding()
            ForEach(1..<51) { idx in
                if shouldStick {
                    Text("Heading \(idx)")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .sticky(isTappable: isTappable)
                } else {
                    Text("Heading \(idx)")
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
