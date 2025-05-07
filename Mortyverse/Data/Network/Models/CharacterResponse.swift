struct CharacterResponse: Decodable {
    let info: PageInfo
    let results: [CharacterDTO]
}
