import SwiftUI

struct ShareView: View {
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)

                Text("Add to Stash")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Share extension will be fully implemented in Phase 4")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Stash My Stuff")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            self.dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            // Save action to be implemented
                            self.dismiss()
                        }
                    }
                }
            #endif
        }
    }
}

#Preview {
    ShareView()
}
