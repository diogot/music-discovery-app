import Foundation

public enum ArtworkURLResolver {

    /// Replaces the size component in an iTunes artwork URL.
    ///
    /// iTunes artwork URLs follow the pattern `https://…/100x100bb.jpg`.
    /// This method swaps `100x100` for the requested square dimension.
    public static func resolve(_ url: URL, size: Int) -> URL? {
        let replaced = url.absoluteString.replacingOccurrences(
            of: "100x100",
            with: "\(size)x\(size)"
        )
        return URL(string: replaced)
    }
}
