import SwiftUI

struct ContentView: View {
    var cards = [
        Card(title: "EdgeOne", imageName: "edgeOne", subtitle: "View in AR"),
        Card(title: "Helpdesk", imageName: "edgeTwo", subtitle: "Get support"),
        Card(title: "Website", imageName: "edgeThree", subtitle: "Visit our website")
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
            
            // Cards
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(cards) { card in
                        CardView(card: card)
                    }
                }
            }
        }
        .padding()
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
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
            
            Text(card.title)
                .font(.headline)
            
            Text(card.subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .frame(maxWidth: .infinity) // this will make the CardView as wide as possible, respecting the padding
    }
}

struct Card: Identifiable {
    var id = UUID()
    var title: String
    var imageName: String
    var subtitle: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
