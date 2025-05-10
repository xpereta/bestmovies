import Foundation

struct Character: Identifiable, Equatable {
    let id: Int
    let name: String
    let created: Date
    let image: String
    let species: String
    let gender: String
}
