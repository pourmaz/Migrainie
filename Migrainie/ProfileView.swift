import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section("Basic info") {
                        TextField("Name or nickname",
                                  text: $appState.profile.username)
                        
                        TextField("Age",
                                  text: $appState.profile.age)
                            .keyboardType(.numberPad)
                        
                        Picker("Sex / gender", selection: $appState.profile.sex) {
                            Text("Not set").tag("")          // default
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                            Text("Other").tag("Other")
                        }
                        .pickerStyle(.segmented)
                    }

                    
                    Section("Body metrics") {
                        TextField("Height (cm)",
                                  text: $appState.profile.heightCm)
                            .keyboardType(.decimalPad)
                        
                        TextField("Weight (kg)",
                                  text: $appState.profile.weightKg)
                            .keyboardType(.decimalPad)
                    }
                    
                    Section("Health background") {
                        TextField("Diagnosed health conditions",
                                  text: $appState.profile.healthConditions,
                                  axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                            .textInputAutocapitalization(.sentences)
                        
                        TextField("Current medications",
                                  text: $appState.profile.medications,
                                  axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                            .textInputAutocapitalization(.sentences)
                        
                        TextField("Allergies (if any)",
                                  text: $appState.profile.allergies,
                                  axis: .vertical)
                            .lineLimit(2, reservesSpace: true)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
//
//  ProfileView.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 04/12/25.
//

