# Music Discovery

A music discovery app for iOS built with SwiftUI, Swift 6 concurrency, and
SwiftData. Search for songs via the Apple iTunes Search API, play previews,
browse albums, and keep track of recently played songs offline.

## Screenshots

<!-- TODO: Add simulator screenshots -->

## Features

- **Search** songs with debounced input and paginated results
- **Play** 30-second iTunes previews with playback controls (play/pause,
  forward, backward, seek, repeat)
- **Browse albums** with full track listings
- **Offline-first** — recently played songs are cached with SwiftData and
  available without a network connection
- **Pull to refresh** on the home screen
- **Localized** with String Catalog (English)

## Tech Stack

| | |
|---|---|
| Language | Swift 6.3 |
| UI | SwiftUI (iOS 26+) |
| Architecture | MVVM with `@Observable` |
| Persistence | SwiftData |
| Concurrency | Structured concurrency (async/await, actors) |
| API | [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/Searching.html) |

## Project Structure

```
App/                             # iOS target
  Screens/
    Splash/                      # Launch screen with gradient + 3D icon
    Songs/                       # Home — search bar, song list, recently played
    Player/                      # Playback controls, timeline, artwork
    MoreOptions/                 # Bottom sheet (view album, etc.)
    Album/                       # Album header + track listing
  Services/
    NowPlayingManager.swift      # Shared playback state across screens

Packages/
  NetworkService/                # Generic HTTP layer (zero dependencies)
  iTunesAPI/                     # iTunes endpoints + DTOs
  Models/                        # SwiftData @Model classes + repository protocols
  AppCore/                       # Repositories, AudioPlayer, DTO mapping
```

### Dependency Graph

```
NetworkService          Models
     |                    |
  iTunesAPI               |
     \                   /
       \               /
         AppCore
            |
         iOS App
```

Each package is an independent Swift Package with its own sources and tests.

## Architecture

**MVVM** — ViewModels are `@Observable` classes on `@MainActor`. Views are
declarative and state-driven. Dependencies are injected via initializers.

**Offline-first** — Repositories fetch from the network and upsert into
SwiftData. The home screen shows cached recently played songs when offline.

**Network abstraction** — `NetworkService` is a protocol, making the HTTP
implementation replaceable without affecting other layers. `iTunesAPI` builds
typed endpoints on top. The app target never imports `NetworkService` or
`iTunesAPI` directly — `AppCore`'s `RepositoryFactory` hides the wiring.

**Modular packages** — Dependency direction is enforced by SPM. Each package
can be built and tested independently.

## Testing

Comprehensive test coverage using the Swift Testing framework (`@Test`,
`@Suite`, `#expect`).

| Target | Suites | Description |
|---|---|---|
| NetworkService | 3 | Request building, URL session, error mapping |
| iTunesAPI | 5 | DTO decoding, request factories, service layer |
| Models | 5 | Model init/computed properties, SwiftData persistence |
| AppCore | 5 | DTO mapping, repositories, AudioPlayer |
| App | 3 | SongsViewModel, NowPlayingManager, AlbumViewModel |

## Build & Run

Requires **Xcode 26.4+** and an **iOS 26+** simulator or device.

```bash
# Open the workspace
open MusicDiscovery.xcworkspace

# Or run package tests from the command line
cd Packages/NetworkService && swift test
cd Packages/iTunesAPI && swift test
cd Packages/Models && swift test
cd Packages/AppCore && swift test
```
