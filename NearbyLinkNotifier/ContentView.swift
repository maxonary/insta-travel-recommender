import SwiftUI

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct ContentView: View {
    @State private var links: [Link] = []
    @State private var errorMessage: ErrorMessage?

    var body: some View {
        NavigationView {
            List {
                ForEach(links, id: \.link) { link in
                    Button(action: {
                        openLink(link.link) // Open link in Safari when clicked
                    }) {
                        VStack(alignment: .leading) {
                            Text(link.link)
                                .font(.headline)
                                .foregroundColor(.blue) // Indicate it is clickable
                            if let location = link.location, let lat = location["lat"], let lng = location["lng"] {
                                Text("Lat: \(lat), Lng: \(lng)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteLink)
            }
            .onAppear(perform: fetchLinks)
            .navigationTitle("Nearby Links")
            .alert(item: $errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    // Open the link in Safari
    func openLink(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            self.errorMessage = ErrorMessage(message: "Invalid URL: \(urlString)")
            return
        }
        UIApplication.shared.open(url)
    }

    func fetchLinks() {
        APIService.shared.fetchAllLinks { fetchedLinks in
            DispatchQueue.main.async {
                if let fetchedLinks = fetchedLinks {
                    self.links = fetchedLinks
                } else {
                    self.errorMessage = ErrorMessage(message: "Failed to fetch links.")
                }
            }
        }
    }

    func deleteLink(at offsets: IndexSet) {
        offsets.forEach { index in
            let link = links[index]
            APIService.shared.deleteLink(link.link) { success in
                DispatchQueue.main.async {
                    if success {
                        self.links.remove(at: index)
                    } else {
                        self.errorMessage = ErrorMessage(message: "Failed to delete link.")
                    }
                }
            }
        }
    }
}
