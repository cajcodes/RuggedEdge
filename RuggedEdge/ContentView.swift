import SwiftUI
import UIKit
import QuickLook
import ARKit

struct Card: Identifiable {
    var id = UUID()
    var title: String
    var imageName: String
    var subtitle: String
    var action: (() -> Void)?
}

class ARQuickLookViewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    var resourceName: String
    var allowScaling: Bool
    var hasPresentedQuickLook = false  // New property

    init(resourceName: String, allowScaling: Bool) {
        self.resourceName = resourceName
        self.allowScaling = allowScaling
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasPresentedQuickLook {
            let previewController = QLPreviewController()
            previewController.dataSource = self
            previewController.delegate = self
            present(previewController, animated: true, completion: nil)
            
            hasPresentedQuickLook = true  // Update the property
        }
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "usdz") else { fatalError("Couldn't find the supported input file.") }
        let url = URL(fileURLWithPath: path)
        let item = ARQuickLookPreviewItem(fileAt: url)
        item.allowsContentScaling = allowScaling
        return item
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        dismiss(animated: true, completion: nil)
    }
}


struct ContentView: View {
    var cards: [Card]

    init() {
        cards = [
            Card(title: "EdgeOne", imageName: "EdgeOneDevice", subtitle: "View in AR", action: {}),
            Card(title: "Helpdesk", imageName: "RuggedHelpdesk", subtitle: "Coming Soon", action: {}),
            Card(title: "Website", imageName: "RuggedSite", subtitle: "Visit our website", action: { UIApplication.shared.open(URL(string: "https://www.ruggededge.ai")!) })
        ]

        cards[0].action = {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let arQuickLookVC = ARQuickLookViewController(resourceName: "RuggedDevice5", allowScaling: true)
                window.rootViewController?.present(arQuickLookVC, animated: true, completion: nil)
            }
        }
    }

    var body: some View {
        VStack {
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
                .padding(.horizontal, 10)
            }
        }
        .padding(0)
        .background(Color(red: 26/255, green: 36/255, blue: 51/255))
        .edgesIgnoringSafeArea(.all)
    }
}

struct CardView: View {
    var card: Card
    
    var body: some View {
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
        .padding()
        .background(Color.white)

        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .onTapGesture {
            card.action?()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
