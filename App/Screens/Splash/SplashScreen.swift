import SwiftUI

struct SplashScreen: View {

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0.0),
                    .init(color: Color(red: 0, green: 0.53, blue: 0.63), location: 1.0),
                ],
                startPoint: UnitPoint(x: -0.1, y: 1),
                endPoint: UnitPoint(x: 3.6, y: 0)
            )
            .ignoresSafeArea()
            Image(.splashMusicNote)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
        }
    }
}

#Preview {
    SplashScreen()
}
