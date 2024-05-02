//
//  ContentView.swift
//  password manager 1
//
//  Created by Thiru on 01/05/24.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PasswordData.accountName, ascending: true)],
        animation: .default)
    private var items: FetchedResults<PasswordData>
    
    @State private var isShowingAddView = false
    @State private var selectedPasswordData: PasswordData? = nil
    @State private var isShowingEditView = false
    
    // Dictionary to track password visibility for each entry
    @State private var passwordVisibility: [String: Bool] = [:]
    
    // Method to delete password data
    func deletePasswordData(at offsets: IndexSet) {
        for i in offsets {
            let passwordData = items[i]
            viewContext.delete(passwordData)
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete data: \(error)")
            }
        }
    }
    
    // Function to authenticate using Face ID or Touch ID
    func authenticateUser(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Check if the device supports biometric authentication
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to edit entry") { success, evaluationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true)
                    } else {
                        // Handle authentication failure
                        print("Authentication failed: \(evaluationError?.localizedDescription ?? "Unknown error")")
                        completion(false)
                    }
                }
            }
        } else {
            // Biometric authentication not available
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            completion(false)
        }
    }
    
    // Method to handle editing password data with biometric authentication
    func handleEditPasswordData(passwordData: PasswordData) {
        // Authenticate the user before allowing them to edit the password data
        authenticateUser { authenticated in
            if authenticated {
                // If authentication is successful, present the EditPasswordView
                selectedPasswordData = passwordData
                isShowingEditView = true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Password Manager")) {
                    ForEach(items) { entry in
                        VStack(alignment: .leading) {
                            Text("Account: \(entry.accountName ?? "")")
                            Text("Username: \(entry.username ?? "")")
                            
                            // Get visibility state for the current entry using its unique ID
                            let isEntryPasswordVisible = passwordVisibility[entry.pid ?? ""] ?? false
                            
                            // Password field with eye button for visibility toggle
                            HStack {
                                if isEntryPasswordVisible {
                                    // Display password in a text field
                                    TextField("Password", text: .constant(entry.password ?? ""))
                                        .disabled(true)
                                } else {
                                    // Use SecureField to hide password
                                    SecureField("Password", text: .constant(entry.password ?? ""))
                                        .disabled(true)
                                }
                                
                                // Eye button to toggle password visibility for the current entry
                                Button(action: {
                                    // Authenticate the user before toggling visibility
                                    authenticateUser { authenticated in
                                        if authenticated {
                                            // Toggle visibility state for the current entry
                                            passwordVisibility[entry.pid ?? ""] = !isEntryPasswordVisible
                                        }
                                    }
                                }) {
                                    Image(systemName: isEntryPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        // Add swipe actions for editing and deleting each item
                        .swipeActions(edge: .trailing) {
                            // Edit action
                            Button(action: {
                                // Call the method to handle editing password data with biometric authentication
                                handleEditPasswordData(passwordData: entry)
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)

                            // Delete action
                            Button(action: {
                                deletePasswordData(at: IndexSet(integer: items.firstIndex(of: entry)!))
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                    .onDelete(perform: deletePasswordData)
                }
            }
            .navigationTitle("Password Manager")
            .navigationBarItems(trailing: Button(action: {
                isShowingAddView.toggle()
            }) {
                Text("Add")
            })
            .sheet(isPresented: $isShowingAddView) {
                AddPasswordView()
            }
            // Present the EditPasswordView when `isShowingEditView` is true
            .sheet(isPresented: $isShowingEditView) {
                if let selectedPasswordData = selectedPasswordData {
                    EditPasswordView(passwordData: selectedPasswordData)
                }
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}


