# Music Discovery App

A personal project to explore SwiftUI, Swift 6 concurrency, and SwiftData by
building a music discovery app powered by the Apple iTunes Search API.

## Tech Stack

- **Language:** Swift 6.3
- **UI:** SwiftUI
- **Architecture:** MVVM
- **Persistence:** SwiftData
- **Concurrency:** Swift structured concurrency (async/await, actors)
- **Platforms:** iOS, iPadOS (watchOS planned)

## Project Structure

```
MusicDiscovery/                  # Xcode project
  App/                           # iOS/iPadOS target
    MusicDiscoveryApp.swift
    Navigation/
    Screens/
      Splash/
      Songs/
      Player/
      MoreOptions/
      Album/

Packages/
  NetworkService/                # Generic HTTP layer (zero dependencies)
  iTunesAPI/                     # iTunes endpoints + DTOs (→ NetworkService)
  Models/                        # SwiftData @Model classes + repository protocols
  AppCore/                       # Repositories, AudioPlayer (→ iTunesAPI, Models)
```

### Dependency Graph

```
NetworkService (zero dependencies)
     ↓
iTunesAPI

Models (zero package dependencies, uses SwiftData framework)

     ↓ all converge ↓

AppCore (depends on iTunesAPI, Models)
     ↓
iOS App / watchOS App
```

Each package is an independent Swift Package with its own sources and tests.

## Key Design Decisions

- **Network abstraction layer** — `NetworkService` protocol is generic and
  implementation-replaceable. `iTunesAPI` builds on top with typed endpoints.
- **MVVM** — ViewModels use `@Observable`; Views are declarative and state-driven
- **Offline-first** — SwiftData cache with `@Query` integration in SwiftUI;
  network fetches update the cache
- **Modular** — local Swift packages enforce dependency direction and enable
  code sharing across platform targets

## Screens

1. Splash
2. Songs (Home) — search bar + recently played list
3. Song Details (Player) — album art, playback controls, timeline
4. More Options (bottom sheet) — contextual actions like "View album"
5. Album — header with artwork, track listing

## Build & Run

Requires Xcode 26.4+. Open the Xcode project and run on an iOS 26+ simulator or device.
