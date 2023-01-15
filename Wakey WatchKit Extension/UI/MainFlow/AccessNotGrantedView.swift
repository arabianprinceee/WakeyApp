import SwiftUI

struct AccessNotGrantedView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Image(systemName: "applewatch.side.right")
                        .foregroundColor(.blue)
                        .opacity(0.85)
                        .font(.system(size: 40))
                    Image(systemName: "waveform.path.ecg")
                        .foregroundColor(.red)
                        .opacity(0.75)
                        .font(.system(size: 40))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Wakey requires an access for your health data to make smart alarm usable.")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 12))
                    Text("Also make sure you have turned on heart tracking on your Apple Watch.")
                        .font(.system(size: 12))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
        }
    }
}

struct AccessNotGrantedView_Previews: PreviewProvider {
    static var previews: some View {
        AccessNotGrantedView()
    }
}
