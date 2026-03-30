import Foundation
import Testing
@testable import Models

@Suite("ArtworkURLResolver")
struct ArtworkURLResolverTests {

    @Test("resolves standard iTunes artwork URL to requested size")
    func resolvesStandardURL() throws {
        let input = try #require(URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/ab/cd/ef/abcdef/100x100bb.jpg"))
        let result = ArtworkURLResolver.resolve(input, size: 600)

        #expect(result?.absoluteString == "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/ab/cd/ef/abcdef/600x600bb.jpg")
    }

    @Test("resolves to custom size")
    func resolvesCustomSize() throws {
        let input = try #require(URL(string: "https://example.com/art/100x100bb.jpg"))
        let result = ArtworkURLResolver.resolve(input, size: 300)

        #expect(result?.absoluteString == "https://example.com/art/300x300bb.jpg")
    }

    @Test("returns URL unchanged when pattern not found")
    func noPatternMatch() throws {
        let input = try #require(URL(string: "https://example.com/art/200x200bb.jpg"))
        let result = ArtworkURLResolver.resolve(input, size: 600)

        #expect(result?.absoluteString == input.absoluteString)
    }
}
