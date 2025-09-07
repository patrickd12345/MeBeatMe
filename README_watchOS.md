# MeBeatMe watchOS App

This watchOS app captures running workouts on Apple Watch, stores them locally, and synchronizes to the existing Ktor server.

## Build & Run
1. Open the Xcode project generated from the `watchos` module.
2. Select a watchOS simulator or paired Apple Watch.
3. Provide a `watchos/Secrets.plist` with a `token` key for server auth. A template exists at `watchos/Secrets.plist.example`.
4. Run the app. The first launch will request Health permissions.

## Configuration
- Server base URL is defined in `AppConfig.swift`.
- The bearer token is read from `Secrets.plist`.

## Known Limitations
- Background sync and complications are not implemented.
- Unit tests require a macOS environment with the Apple toolchain.
