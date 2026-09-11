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

## GitHub iOS Build

The repository includes `MerLuy.xcodeproj` and a GitHub Actions workflow at `.github/workflows/build-ios.yml`. Open the **Actions** tab on GitHub and run **Build iOS IPA**. The workflow uploads `MerLuy-unsigned.ipa` as an artifact.

This is an unsigned IPA for free CI builds. Installing on a physical iPhone requires Apple Developer signing, provisioning, and certificates configured as GitHub Actions secrets.

Admin tools are demo-only local features: create an Admin account from Settings, then use the Admin tab for sample dashboard metrics, local notifications, and a no-payment Pro Beta plan preview. Production accounts, remote notifications, and real analytics require a secure backend.

To test Pro Beta without a server, open Admin > Beta Plans, select Pro Beta, and enter `MERLUY-PRO-BETA`. The activation is stored locally on the device for testing only.
