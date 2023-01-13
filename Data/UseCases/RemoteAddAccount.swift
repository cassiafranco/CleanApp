import Foundation
import Domain

public final class RemoteAddAccount: AddAccount {
    private let url: URL
    private let httpClient: HttpPostClient
    
    public init(url: URL, httpClien: HttpPostClient) {
        self.url = url
        self.httpClient = httpClien
    }
    public func add(addAccountModel: AddAccountModel, completion: @escaping (Result<AccountModel, DomainError>) -> Void) {
        httpClient.post(to: url, with: addAccountModel.toData()) { result in
            switch result {
            case .success(let data):
                if let model: AccountModel = data.toModel() {
                    completion(.success(model))
                }
            case .failure: completion(.failure(.unexpected))
            }
        }
    }
}

