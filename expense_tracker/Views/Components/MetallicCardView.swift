import SwiftUI
import CoreMotion
import Combine

// MARK: - Motion Manager
class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var pitch: Double = 0
    @Published var roll: Double = 0

    init() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion = motion, let self = self else { return }
            withAnimation(.interpolatingSpring(stiffness: 80, damping: 14)) {
                self.pitch = motion.attitude.pitch
                self.roll = motion.attitude.roll
            }
        }
    }

    deinit { motionManager.stopDeviceMotionUpdates() }
}

// MARK: - Metallic Card
struct MetallicCardView: View {
    let summary: MonthlySummary
    
    @StateObject private var motion = MotionManager()
    @State private var time: Double = 0
    @State private var animateNumbers: Bool = false

    private func clamp(_ v: Double, _ lo: Double, _ hi: Double) -> Double {
        min(max(v, lo), hi)
    }

    private var tiltX: Double { clamp(motion.pitch * 18, -25, 25) }
    private var tiltY: Double { clamp(motion.roll * 18, -25, 25) }
    private var normX: CGFloat { CGFloat(0.5 + clamp(motion.roll * 0.6, -0.5, 0.5)) }
    private var normY: CGFloat { CGFloat(0.5 - clamp(motion.pitch * 0.6, -0.5, 0.5)) }

    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Ambient floor glow
            Ellipse()
                .fill(RadialGradient(
                    colors: [Color.white.opacity(0.07), .clear],
                    center: .center, startRadius: 10, endRadius: 180
                ))
                .frame(width: 320, height: 100)
                .offset(x: CGFloat(-tiltY * 1.2), y: 160 + CGFloat(tiltX * 0.5))
                .blur(radius: 28)

            // The Card
            cardBody
                .frame(width: 370, height: 234)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(rimBorder)
                .shadow(color: .black.opacity(0.6), radius: 30,
                        x: CGFloat(-tiltY * 1.4), y: CGFloat(tiltX * 1.4))
                .shadow(color: .black.opacity(0.3), radius: 10,
                        x: CGFloat(-tiltY * 0.5), y: CGFloat(tiltX * 0.5))
                .shadow(color: Color(white: 0.7).opacity(0.04), radius: 60)
                .rotation3DEffect(.degrees(tiltX), axis: (x: 1, y: 0, z: 0), perspective: 0.4)
                .rotation3DEffect(.degrees(tiltY), axis: (x: 0, y: 1, z: 0), perspective: 0.4)

            VStack {
                Spacer()
                Text("TILT YOUR DEVICE")
                    .font(.system(size: 10, weight: .regular))
                    .tracking(3)
                    .foregroundColor(.white.opacity(0.15))
                    .padding(.bottom, 36)
            }
        }
        .onReceive(timer) { _ in time += 1.0 / 60.0 }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                animateNumbers = true
            }
        }
    }

    // MARK: - Rim Border
    private var rimBorder: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0.35 * Double(1.0 - normY)), location: 0),
                        .init(color: .white.opacity(0.06), location: 0.35),
                        .init(color: .black.opacity(0.06), location: 0.7),
                        .init(color: .white.opacity(0.12 * Double(normY)), location: 1),
                    ],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: 0.8
            )
    }

    // MARK: - All Layers
    private var cardBody: some View {
        ZStack {
            // 1. Base metal
            metalBase
            // 2. Brushed texture (fine lines)
            brushedTexture
            // 3. Second brush pass (thicker)
            deepBrush
            // 4. Anisotropic streaks that shift with gyro
            anisotropicStreaks
            // 5. Main specular (large soft glow)
            mainSpecular
            // 6. Hot specular (small intense)
            hotSpecular
            // 7. Edge catch lights (top/bottom/left/right)
            edgeCatchLights
            // 8. Rolling light sheen (sweeps across)
            rollingSheen
            // 9. Holographic rainbow
            holoSheen
            // 10. Content
            cardContent
        }
    }

    // MARK: 1 — Base Metal
    private var metalBase: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.84, green: 0.86, blue: 0.88), location: 0.0),
                .init(color: Color(red: 0.73, green: 0.76, blue: 0.79), location: 0.18),
                .init(color: Color(red: 0.82, green: 0.84, blue: 0.86), location: 0.32),
                .init(color: Color(red: 0.68, green: 0.71, blue: 0.74), location: 0.50),
                .init(color: Color(red: 0.78, green: 0.80, blue: 0.83), location: 0.65),
                .init(color: Color(red: 0.72, green: 0.74, blue: 0.77), location: 0.80),
                .init(color: Color(red: 0.80, green: 0.82, blue: 0.85), location: 1.0),
            ],
            startPoint: UnitPoint(x: 0.2 + Double(normX) * 0.15, y: 0),
            endPoint: UnitPoint(x: 0.8 - Double(normX) * 0.15, y: 1)
        )
    }

    // MARK: 2 — Fine Brushed Lines
    private var brushedTexture: some View {
        Canvas { ctx, size in
            for i in 0..<Int(size.height) {
                let y = CGFloat(i)
                let s = sin(Double(i) * 0.73) * cos(Double(i) * 1.37) + sin(Double(i) * 3.19) * 0.5
                let a = 0.025 + s * 0.022
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y + 0.25))
                p.addLine(to: CGPoint(x: size.width, y: y + 0.25))
                if a > 0 {
                    ctx.stroke(p, with: .color(.white.opacity(a)), lineWidth: 0.5)
                } else {
                    ctx.stroke(p, with: .color(.black.opacity(-a * 0.5)), lineWidth: 0.5)
                }
            }
        }
        .blendMode(.overlay)
        .opacity(0.9)
    }

    // MARK: 3 — Deeper Brush Accents
    private var deepBrush: some View {
        Canvas { ctx, size in
            for i in stride(from: 0, to: Int(size.height), by: 2) {
                let y = CGFloat(i)
                let s = cos(Double(i) * 0.53) * sin(Double(i) * 2.7 + 0.8)
                let a = max(0, 0.02 + s * 0.018)
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: size.width, y: y))
                ctx.stroke(p, with: .color(.white.opacity(a)), lineWidth: 1.2)
            }
        }
        .blendMode(.softLight)
        .opacity(0.7)
    }

    // MARK: 4 — Anisotropic Streaks
    private var anisotropicStreaks: some View {
        let shift = Double(normX - 0.5) * 0.25
        return LinearGradient(
            stops: [
                .init(color: .clear,                 location: 0.0),
                .init(color: .white.opacity(0.00),   location: 0.08 + shift),
                .init(color: .white.opacity(0.09),   location: 0.13 + shift),
                .init(color: .white.opacity(0.00),   location: 0.18 + shift),
                .init(color: .clear,                 location: 0.25),
                .init(color: .white.opacity(0.07),   location: 0.40 + shift * 0.6),
                .init(color: .white.opacity(0.00),   location: 0.45 + shift * 0.6),
                .init(color: .clear,                 location: 0.52),
                .init(color: .white.opacity(0.10),   location: 0.67 - shift * 0.4),
                .init(color: .white.opacity(0.00),   location: 0.72 - shift * 0.4),
                .init(color: .clear,                 location: 0.80),
                .init(color: .white.opacity(0.05),   location: 0.90 - shift),
                .init(color: .clear,                 location: 1.0),
            ],
            startPoint: .leading, endPoint: .trailing
        )
        .blendMode(.screen)
    }

    // MARK: 5 — Main Specular
    private var mainSpecular: some View {
        RadialGradient(
            colors: [
                .white.opacity(0.38),
                .white.opacity(0.12),
                .white.opacity(0.02),
                .clear
            ],
            center: UnitPoint(x: Double(normX), y: Double(normY)),
            startRadius: 5, endRadius: 250
        )
        .blendMode(.screen)
    }

    // MARK: 6 — Hot Specular
    private var hotSpecular: some View {
        RadialGradient(
            colors: [.white.opacity(0.55), .white.opacity(0.15), .clear],
            center: UnitPoint(
                x: Double(normX) * 1.1 - 0.05,
                y: Double(normY) * 1.1 - 0.05
            ),
            startRadius: 0, endRadius: 100
        )
        .blendMode(.screen)
        .opacity(0.5)
    }

    // MARK: 7 — Edge Catch Lights
    private var edgeCatchLights: some View {
        ZStack {
            LinearGradient(colors: [.white.opacity(0.18 * Double(1.0 - normY)), .clear],
                           startPoint: .top, endPoint: .center)
                .frame(height: 60).frame(maxHeight: .infinity, alignment: .top)
                .blendMode(.screen)

            LinearGradient(colors: [.clear, .white.opacity(0.08 * Double(normY))],
                           startPoint: .center, endPoint: .bottom)
                .frame(height: 40).frame(maxHeight: .infinity, alignment: .bottom)
                .blendMode(.screen)

            LinearGradient(colors: [.white.opacity(0.10 * Double(1.0 - normX)), .clear],
                           startPoint: .leading, endPoint: .center)
                .frame(width: 40).frame(maxWidth: .infinity, alignment: .leading)
                .blendMode(.screen)

            LinearGradient(colors: [.clear, .white.opacity(0.10 * Double(normX))],
                           startPoint: .center, endPoint: .trailing)
                .frame(width: 40).frame(maxWidth: .infinity, alignment: .trailing)
                .blendMode(.screen)
        }
    }

    // MARK: 8 — Rolling Light Sheen
    private var rollingSheen: some View {
        let pos = Double(normX)
        return LinearGradient(
            stops: [
                .init(color: .clear,                 location: max(0, pos - 0.18)),
                .init(color: .white.opacity(0.14),   location: pos - 0.04),
                .init(color: .white.opacity(0.30),   location: pos),
                .init(color: .white.opacity(0.14),   location: pos + 0.04),
                .init(color: .clear,                 location: min(1, pos + 0.18)),
            ],
            startPoint: .leading, endPoint: .trailing
        )
        .blendMode(.screen)
        .opacity(0.45)
    }

    // MARK: 9 — Holographic Rainbow
    private var holoSheen: some View {
        AngularGradient(
            colors: [
                .red.opacity(0.035), .orange.opacity(0.025),
                .yellow.opacity(0.03), .green.opacity(0.03),
                .cyan.opacity(0.035), .blue.opacity(0.04),
                .purple.opacity(0.03), .pink.opacity(0.03),
                .red.opacity(0.035),
            ],
            center: UnitPoint(x: Double(normX), y: Double(normY)),
            startAngle: .degrees(time * 8),
            endAngle: .degrees(time * 8 + 360)
        )
        .blendMode(.colorDodge)
        .opacity(0.9)
    }

    // ── Embossed text style ──
    private var embossedText: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.30, green: 0.32, blue: 0.36),
                Color(red: 0.22, green: 0.24, blue: 0.28),
                Color(red: 0.35, green: 0.37, blue: 0.40),
            ],
            startPoint: .top, endPoint: .bottom
        )
    }

    // MARK: - Card Content
    private var cardContent: some View {
        VStack(spacing: 16) {
            // Month display
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundStyle(embossedText)
                    .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 0.8)
                
                Text(monthText)
                    .font(.system(size: 12, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(embossedText)
                    .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 0.8)
            }
            
            // Balance
            VStack(spacing: 4) {
                Text("TOTAL BALANCE")
                    .font(.system(size: 9, weight: .regular))
                    .tracking(2)
                    .foregroundColor(Color(red: 0.35, green: 0.37, blue: 0.40).opacity(0.55))
                
                Text(formatCurrency(summary.balance))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(embossedText)
                    .shadow(color: .white.opacity(0.35), radius: 0, x: 0, y: 1)
                    .opacity(animateNumbers ? 1 : 0)
                    .scaleEffect(animateNumbers ? 1.0 : 0.8)
            }
            
            // Divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Color(red: 0.35, green: 0.37, blue: 0.40).opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 40)
            
            // Income and Expenses
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.green.opacity(0.7))
                        
                        Text("INCOME")
                            .font(.system(size: 8, weight: .regular))
                            .tracking(1.5)
                            .foregroundColor(Color(red: 0.35, green: 0.37, blue: 0.40).opacity(0.55))
                    }
                    
                    Text(formatCurrency(summary.totalIncome))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(embossedText)
                        .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 1)
                        .opacity(animateNumbers ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Color(red: 0.35, green: 0.37, blue: 0.40).opacity(0.3))
                    .frame(width: 1, height: 30)
                
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.red.opacity(0.7))
                        
                        Text("EXPENSES")
                            .font(.system(size: 8, weight: .regular))
                            .tracking(1.5)
                            .foregroundColor(Color(red: 0.35, green: 0.37, blue: 0.40).opacity(0.55))
                    }
                    
                    Text(formatCurrency(summary.totalExpenses))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(embossedText)
                        .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 1)
                        .opacity(animateNumbers ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(24)
    }
    
    // MARK: - Helper Methods
    
    private var monthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: summary.month).uppercased()
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        
        let nsDecimal = value as NSDecimalNumber
        return formatter.string(from: nsDecimal) ?? "$0.00"
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        MetallicCardView(summary: MonthlySummary(
            month: Date(),
            totalIncome: 5000.00,
            totalExpenses: 3200.50,
            transactionCount: 25
        ))
        .padding()
    }
    .preferredColorScheme(.dark)
}
