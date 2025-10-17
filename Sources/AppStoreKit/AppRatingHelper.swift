//
//  AppRatingHelper.swift
//  RatingHelper
//
//  Created by hong on 10/16/25.
//

import SwiftUI
import StoreKit

@available(iOS 16.0, *)
public extension View {
    @ViewBuilder
    func presentAppRating(
        initialCondition: @escaping () async -> Bool,
        askLaterCondition: @escaping ()  async -> Bool
    ) -> some View {
        self.modifier(AppRatingModifier(initialCondition: initialCondition, askLaterCondition: askLaterCondition))
    } 
}

@available(iOS 16.0, *)
fileprivate
struct AppRatingModifier: ViewModifier {
    var initialCondition:() async -> Bool
    var askLaterCondition:() async -> Bool
    
    @AppStorage("isRatingInteractionComplete") private var isCompleted: Bool = false
    @AppStorage("isInitialPrompt") private var isInitialPrompShown: Bool = false
    @State private var showAlert: Bool = false
    @Environment(\.requestReview) private var requestView
    
    func body(content: Content) -> some View {
        content
            .task {
                guard !isCompleted else {
                    print("isCompleted")
                    return
                }
                
                let condition = isInitialPrompShown ? (await askLaterCondition()) : (await initialCondition())
                
                if condition {
                    showAlert = true
                }
                
            }
            .alert("Would you like to rate the app", isPresented: $showAlert) {
                Button(isInitialPrompShown ? "Yes!" : "Yes, Continue!") {
                    requestView()
                    isCompleted = true
                }
                .keyboardShortcut(.defaultAction)
                
                if isInitialPrompShown {
                    Button("Nope", role: .cancel) {
                        isCompleted = true
                    }
                } else {
                    Button("Ask Later", role: .cancel) {
                        isInitialPrompShown = true
                    }
                    
                    Button("Never ask again", role: .destructive) {
                        isCompleted = true
                    }
                }
            }
    }
}
