import XCTest
import Domain
import Data

class RemoteAddAccountTests: XCTestCase {
    
    func test_add_should_call_httpClient_whith_correct_url() {
        let url = URL(string: "http://any-url.com")!
        let (sut, httpClientSpy) =  makeSut(url: url)
        sut.add(addAccountModel: makeAddAccountModel()) { _ in }
        XCTAssertEqual(httpClientSpy.urls, [url])
    }
    func test_add_should_call_httpClient_with_correct_data() {
        let (sut, httoClientSpy) = makeSut()
        let addAccountModel = self.makeAddAccountModel()
        sut.add(addAccountModel: addAccountModel) { _ in }
        XCTAssertEqual(httoClientSpy.data, addAccountModel.toData())
    }
    func test_add_should_complete_with_error_if_client_complete_error() {
        let (sut, httoClientSpy) = makeSut()
        let exp = expectation(description: "waiting")
        sut.add(addAccountModel: self.makeAddAccountModel()) { result in
            switch result {
            case .failure(let error): XCTAssertEqual(error,.unexpected)
            case.success: XCTFail("Expected error received \(result) insted")
                
            }
            
            exp.fulfill()
        }
        httoClientSpy.completeWithError(.noConnectivity)
        wait(for: [exp], timeout: 1)
    }
    func test_add_should_complete_with_account_if_client_complete_with_valid_data() {
        let (sut, httoClientSpy) = makeSut()
        let exp = expectation(description: "waiting")
        let expectedAccount = makeAccountModel()
        sut.add(addAccountModel: self.makeAddAccountModel()) { result in
            switch result {
            case.failure: XCTFail("Expected sucess received \(result) insted")
            case .success(let receivedAccount): XCTAssertEqual(receivedAccount, expectedAccount)
            }
            exp.fulfill()
        }
        httoClientSpy.completeWithData(expectedAccount.toData()!)
        wait(for: [exp], timeout: 1)
    }
    func test_add_should_complete_with_error_if_client_complete_with_invalid_data() {
        let (sut, httoClientSpy) = makeSut()
        let exp = expectation(description: "waiting")
        sut.add(addAccountModel: self.makeAddAccountModel()) { result in
            switch result {
            case .failure(let error): XCTAssertEqual(error,.unexpected)
            case.success: XCTFail("Expected error received \(result) insted")
                
            }
            
            exp.fulfill()
        }
        httoClientSpy.completeWithData(Data("invalid_data".utf8))
        wait(for: [exp], timeout: 1)
    }
}

extension RemoteAddAccountTests {
    func makeSut(url: URL = URL(string: "http://any-url.com")!) -> (sut: RemoteAddAccount, httpClienSpy: HttpClientSpy) {
        let httpClientSpy = HttpClientSpy()
        let sut = RemoteAddAccount(url: url, httpClien: httpClientSpy)
        return (sut, httpClientSpy)
    }
    func makeAddAccountModel() -> AddAccountModel {
        return AddAccountModel(name: "any_name", email: "any_email@mail.com", password: "any_password", passwordConfirmation: "any_password")
    }
    func makeAccountModel() -> AccountModel {
        return AccountModel(id: "any_id", name:  "any_name", email: "any_email@mail.com", password:  "any_password")
    }
    
    class HttpClientSpy: HttpPostClient {
        var urls = [URL]()
        var data: Data?
        var completion: ((Result<Data, HttpError>) -> Void)?
        
        func post(to url: URL, with data: Data?, completion: @escaping (Result<Data, HttpError>) -> Void) {
            self.urls.append(url)
            self.data = data
            self.completion = completion
        }
        func completeWithError(_ error: HttpError) {
            completion?(.failure(error))
        }
        func completeWithData(_ data: Data) {
            completion?(.success(data))
        }
    }
}
