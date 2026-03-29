public enum LookupResultItem: Decodable, Sendable {
    case collection(CollectionDTO)
    case track(TrackDTO)

    private enum CodingKeys: String, CodingKey {
        case wrapperType
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let wrapperType = try container.decode(String.self, forKey: .wrapperType)

        switch wrapperType {
        case "collection":
            self = .collection(try CollectionDTO(from: decoder))
        case "track":
            self = .track(try TrackDTO(from: decoder))
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unknown wrapperType: \(wrapperType)"
                )
            )
        }
    }
}
