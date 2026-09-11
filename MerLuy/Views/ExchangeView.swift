import SwiftUI

struct ExchangeView: View {
    @EnvironmentObject private var currencyAPI: CurrencyAPIService
    @EnvironmentObject private var language: LanguageManager
    @State private var amount = "100"
    @State private var from = SampleData.usd
    @State private var to = SampleData.eur

    private var result: Double {
        (Double(amount) ?? 0) * currentRate
    }

    private var currentRate: Double {
        currencyAPI.rate(from: from, to: to) ?? 0.85
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.language.text("Exchange")).font(.system(size: 25, weight: .bold, design: .rounded))
                    Text(language.language.text("Convert between world currencies")).font(.system(size: 13)).foregroundStyle(MerLuyTheme.textSecondary)
                }
                Text(language.language.text("Amount")).font(.system(size: 11)).foregroundStyle(MerLuyTheme.textSecondary)
                TextField("0", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .padding(16)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.10)))

                VStack(spacing: 2) {
                    CurrencySelector(title: language.language.text("From"), currency: $from)
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.3)) { swap(&from, &to) }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(MerLuyTheme.indigo)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, -5)
                        Spacer()
                    }
                    CurrencySelector(title: language.language.text("To"), currency: $to)
                }

                Button(language.language.text("Convert Amount")) { }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(MerLuyTheme.indigo)
                    .clipShape(Capsule())
                    .shadow(color: MerLuyTheme.indigo.opacity(0.35), radius: 12, y: 6)

                ResultCard(result: result, rate: currentRate, from: from, to: to)
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
        }
        .task {
            await currencyAPI.fetchRates()
        }
    }

    private func swap(_ first: inout Currency, _ second: inout Currency) {
        let original = first
        first = second
        second = original
    }
}

private struct CurrencySelector: View {
    let title: String
    @Binding var currency: Currency
    var body: some View {
        Menu {
            ForEach(SampleData.currencies) { option in
                Button {
                    currency = option
                } label: {
                    Text("\(option.flag) \(option.code) - \(option.name)")
                }
            }
        } label: {
            HStack(spacing: 12) {
                Text(currency.flag).font(.system(size: 23)).frame(width: 30, height: 30).background(Color.white.opacity(0.12)).clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.code).font(.system(size: 13, weight: .bold))
                    Text(currency.name).font(.system(size: 10)).foregroundStyle(MerLuyTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.down").font(.system(size: 11, weight: .bold)).foregroundStyle(MerLuyTheme.textSecondary)
            }
            .padding(13)
            .glassCard(radius: 15)
            .overlay(alignment: .topLeading) {
                Text(title).font(.system(size: 9)).foregroundStyle(MerLuyTheme.textSecondary).padding(.leading, 13).padding(.top, 9)
            }
        }
    }
}

private struct ResultCard: View {
    let result: Double
    let rate: Double
    let from: Currency
    let to: Currency
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Result").font(.system(size: 10)).foregroundStyle(MerLuyTheme.positive)
                Spacer()
                Text("1 \(from.code) = \(rate.formatted(.number.precision(.fractionLength(2...4)))) \(to.code)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(MerLuyTheme.positive)
            }
            Text("€" + result.formatted(.number.precision(.fractionLength(2))))
                .font(.system(size: 22, weight: .bold, design: .monospaced))
            Text("\(from.code) to \(to.code) - Updated 1m ago")
                .font(.system(size: 10))
                .foregroundStyle(MerLuyTheme.textSecondary)
        }
        .padding(16)
        .background(LinearGradient(colors: [Color.green.opacity(0.08), MerLuyTheme.indigo.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .glassCard(radius: 18)
    }
}
