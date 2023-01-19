import Foundation

public enum HttpError: Error {
    case noConnectivity
    case badRequest
    case serverError
    case anauthorized
    case forbidden
}
