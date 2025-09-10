import SwiftUI

/// View for app settings and configuration
struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var settingsViewModel
    @State private var showingClearDataAlert = false
    @State private var showingExportData = false
    
    var body: some View {
        NavigationStack {
            List {
                // Units section
                unitsSection
                
                // Preferences section
                preferencesSection
                
                // Data section
                dataSection
                
                // App info section
                appInfoSection
                
                // Support section
                supportSection
                
                // Debug section (only in debug builds)
                #if DEBUG
                debugSection
                #endif
            }
            .navigationTitle("Settings")
            .alert("Clear All Data", isPresented: $showingClearDataAlert) {
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all runs and settings. This action cannot be undone.")
            }
            .sheet(isPresented: $showingExportData) {
                ExportDataView()
            }
        }
    }
    
    private var unitsSection: some View {
        Section("Units") {
            Picker("Distance Unit", selection: $settingsViewModel.units) {
                ForEach(AppConfig.DistanceUnit.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: settingsViewModel.units) { _, newValue in
                settingsViewModel.saveSettings()
            }
        }
    }
    
    private var preferencesSection: some View {
        Section("Preferences") {
            Toggle("Notifications", isOn: $settingsViewModel.enableNotifications)
                .onChange(of: settingsViewModel.enableNotifications) { _, _ in
                    settingsViewModel.saveSettings()
                }
            
            Toggle("Haptic Feedback", isOn: $settingsViewModel.enableHapticFeedback)
                .onChange(of: settingsViewModel.enableHapticFeedback) { _, _ in
                    settingsViewModel.saveSettings()
                }
            
            Toggle("Analytics", isOn: $settingsViewModel.enableAnalytics)
                .onChange(of: settingsViewModel.enableAnalytics) { _, _ in
                    settingsViewModel.saveSettings()
                }
            
            Toggle("Sync", isOn: $settingsViewModel.enableSync)
                .onChange(of: settingsViewModel.enableSync) { _, _ in
                    settingsViewModel.saveSettings()
                }
                .disabled(!settingsViewModel.isSyncAvailable)
        } footer: {
            if !settingsViewModel.isSyncAvailable {
                Text("Sync is not available in this build")
            }
        }
    }
    
    private var dataSection: some View {
        Section("Data") {
            HStack {
                Text("Total Runs")
                Spacer()
                Text("\(settingsViewModel.totalRunsCount)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Total Distance")
                Spacer()
                Text(settingsViewModel.formattedTotalDistance)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Storage Used")
                Spacer()
                Text(settingsViewModel.storageInfo.used)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Available Space")
                Spacer()
                Text(settingsViewModel.storageInfo.available)
                    .foregroundColor(.secondary)
            }
            
            Button("Export Data") {
                showingExportData = true
            }
            
            Button("Clear All Data") {
                showingClearDataAlert = true
            }
            .foregroundColor(.red)
        }
    }
    
    private var appInfoSection: some View {
        Section("App Information") {
            HStack {
                Text("Version")
                Spacer()
                Text(settingsViewModel.appInfo)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Device")
                Spacer()
                Text(settingsViewModel.deviceInfo)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Domain")
                Spacer()
                Text(settingsViewModel.domainInfo)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Supported Formats")
                Spacer()
                Text(settingsViewModel.supportedFileFormats.joined(separator: ", "))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Max File Size")
                Spacer()
                Text(settingsViewModel.maxFileSize)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var supportSection: some View {
        Section("Support") {
            Link("Privacy Policy", destination: URL(string: settingsViewModel.privacyPolicyURL)!)
            
            Link("Terms of Service", destination: URL(string: settingsViewModel.termsOfServiceURL)!)
            
            Link("Support", destination: URL(string: settingsViewModel.supportURL)!)
            
            Button("Send Feedback") {
                sendFeedback()
            }
        }
    }
    
    #if DEBUG
    private var debugSection: some View {
        Section("Debug") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Debug Information")
                    .font(.headline)
                
                Text(settingsViewModel.debugInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            
            Button("Reset Settings") {
                settingsViewModel.resetToDefaults()
            }
            .foregroundColor(.orange)
        }
    }
    #endif
    
    private func clearAllData() {
        do {
            try settingsViewModel.clearAllData()
            AppLogger.logUserAction("data_cleared")
        } catch {
            // Handle error
            AppLogger.logError(error, context: "Failed to clear data")
        }
    }
    
    private func sendFeedback() {
        let email = settingsViewModel.feedbackEmail
        let subject = "MeBeatMe iOS Feedback"
        let body = "Please describe your feedback or issue here..."
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject)&body=\(body)") {
            UIApplication.shared.open(url)
        }
    }
}

/// View for exporting app data
struct ExportDataView: View {
    @Environment(SettingsViewModel.self) private var settingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Export App Data")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("This will create a text file with all your run data for backup or debugging purposes.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                ScrollView {
                    Text(settingsViewModel.exportAppData())
                        .font(.caption)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Button("Share Data") {
                    shareData()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func shareData() {
        let data = settingsViewModel.exportAppData()
        let activityVC = UIActivityViewController(
            activityItems: [data],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    SettingsView()
        .environment(SettingsViewModel())
}
