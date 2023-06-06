import SwiftUI
import UIKit
import QuickLook
import ARKit

struct Card: Identifiable {
    var id = UUID()
    var title: String
    var imageName: String
    var subtitle: String
    var action: () -> Void
}

struct ARQuickLookView: UIViewControllerRepresentable {
    var allowScaling: Bool
    var resourceName: String

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        var parent: ARQuickLookView

        init(_ parent: ARQuickLookView) {
            self.parent = parent
            super.init()
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            guard let path = Bundle.main.path(forResource: parent.resourceName, ofType: "usdz") else { fatalError("Couldn't find the supported input file.") }
            let url = URL(fileURLWithPath: path)
            let item = ARQuickLookPreviewItem(fileAt: url)
            item.allowsContentScaling = parent.allowScaling
            return item
        }
    }
}

struct ContentView: View {
    var cards = [
        Card(title: "EdgeOne", imageName: "RuggedDevice", subtitle: "View in AR", action: { /* ARQuickLookView(allowScaling: true, resourceName: "RuggedDevice.usdz").present() */ }),
        Card(title: "Helpdesk", imageName: "RuggedHelpdesk", subtitle: "Coming Soon", action: {}),
        Card(title: "Website", imageName: "RuggedSite", subtitle: "Visit our website", action: { UIApplication.shared.open(URL(string: "https://www.ruggededge.ai")!) })
    ]

    var body: some View {
        VStack {
            // Spacer to push content down
            Spacer()
                .frame(height: UIScreen.main.bounds.height * 0.05)

            // Logo
            Image("logo_white")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            
            // Title
            Text("Working at the RuggedEdge")
                .font(.custom("MontserratRoman-Bold", size: 27))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Subtitle
            Text("Because success is realized by those who push the limits")
                .font(.custom("MontserratRoman-Light", size: 24))
                .foregroundColor(Color(red: 240/255, green: 83/255, blue: 35/255))
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            // Cards
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(cards) { card in
                        CardView(card: card)
                    }
                }
                .padding(.horizontal, 10) // Adjust this value to set the amount of blue background visible on each side of the cards
            }
        }
        .padding(0) // Remove padding from VStack
        .background(Color(red: 26/255, green: 36/255, blue: 51/255))
        .edgesIgnoringSafeArea(.all)
    }
}

struct CardView: View {
    var card: Card
    
    var body: some View {
        Button(action: card.action) {
            VStack {
                Image(card.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                
                Text(card.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 26/255, green: 36/255, blue: 51/255))
                
                Text(card.subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 240/255, green: 83/255, blue: 35/255))
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
