import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "archivebox.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)

                Text("Stash My Stuff")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Track the journey from 'want' to 'have' to 'loved it'.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Home")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

#Preview {
    ContentView()
}
