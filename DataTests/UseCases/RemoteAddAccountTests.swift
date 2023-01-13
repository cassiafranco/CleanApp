import XCTest
import Domain
import Data

class RemoteAddAccountTests: XCTestCase {
    
    func test_add_should_call_httpClient_whith_correct_url() {
        let url = makeUrl()
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
        expect(sut, comleteWith: .failure(.unexpected), when: {
            httoClientSpy.completeWithError(.noConnectivity)
        })
    }
    func test_add_should_complete_with_account_if_client_complete_with_valid_data() {
        let (sut, httoClientSpy) = makeSut()
        let account = makeAccountModel()
        expect(sut, comleteWith: .success(account), when: {
            httoClientSpy.completeWithData(account.toData()!)
        })
       
    }
    func test_add_should_complete_with_error_if_client_complete_with_invalid_data() {
        let httpClientSpy = HttpClientSpy()
        var sut: RemoteAddAccount? = RemoteAddAccount(url: makeUrl(), httpClien: httpClientSpy)
        var result: Result<AccountModel, DomainError>?
        sut?.add(addAccountModel: makeAddAccountModel()) { result = $0 }
        sut = nil
        httpClientSpy.completeWithError(.noConnectivity)
        XCTAssertNil(result)
    }
    func test_add_should_not_complete_if_sut_has_been_deallocated() {
        let (sut, httoClientSpy) = makeSut()
        expect(sut, comleteWith: .failure(.unexpected), when: {
            httoClientSpy.completeWithData(makeInvalidData())
        })
    }
}

extension RemoteAddAccountTests {
    func makeSut(url: URL = URL(string: "http://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteAddAccount, httpClienSpy: HttpClientSpy) {
        let httpClientSpy = HttpClientSpy()
        let sut = RemoteAddAccount(url: url, httpClien: httpClientSpy)
        checkMemoryLeak(for: sut, file: file, line: line)
        checkMemoryLeak(for: httpClientSpy, file: file, line: line)
        return (sut, httpClientSpy)
    }
    func expect(_ sut: RemoteAddAccount, comleteWith expectedResult: Result<AccountModel, DomainError>, when action:() -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting")
        sut.add(addAccountModel: self.makeAddAccountModel()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.failure(let expectedError), .failure(let receiveError)): XCTAssertEqual(expectedError, receiveError, file: file, line: line)
            case (.success(let expectedAccount), .success(let receivedAccount)): XCTAssertEqual(expectedAccount, receivedAccount, file: file, line: line)
            default: XCTFail("Expected \(expectedResult) received \(receivedResult) instead")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    func makeAddAccountModel() -> AddAccountModel {
        return AddAccountModel(name: "any_name", email: "any_email@mail.com", password: "any_password", passwordConfirmation: "any_password")
    }
    
}
