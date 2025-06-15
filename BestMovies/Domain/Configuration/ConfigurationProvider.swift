import Foundation

protocol ConfigurationProvider {
    var posterBaseURL: String { get }
    var backdropBaseURL: String { get }
    var avatarBaseURL: String { get }
} 