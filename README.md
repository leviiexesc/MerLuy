# MerLuy

A SwiftUI currency exchange mobile app mockup with Home, Exchange, and Settings screens.

## Setup

1. Open Xcode on macOS.
2. Create a new iOS App project named `MerLuy` using SwiftUI and Swift.
3. Replace the generated Swift files with the files in the `MerLuy/` directory, preserving the folder structure.
4. Select an iOS 16+ simulator and run.

The app uses only SwiftUI and Foundation. No external packages are required.

## Live Rates

MerLuy uses the free, keyless Frankfurter exchange-rate API through native `URLSession`. No paid account or API key is required. If the request is unavailable, the built-in sample rates keep the app usable.

Supported currencies include USD, EUR, GBP, JPY, and KHR (Cambodian Riel). English and Khmer language options are available in Settings.
