import XCTest

class RemoteAddAccount {
    private let url: URL
    private let httpClient: HttpClient
    
    init(url: URL, httpClien: HttpClient) {
        self.url = url
        self.httpClient = httpClien
    }
    func add() {
        httpClient.post(url: url)
    }
}

protocol HttpClient {
    func post(url: URL)
}
class RemoteAddAccountTests: XCTestCase {
    
    func test_http_client() {
        let url = URL(string: "http://any-url.com")!
        let httpClientSpy = HttpClientSpy()
        let sut = RemoteAddAccount(url: url, httpClien: httpClientSpy)
        sut.add()
        XCTAssertEqual(httpClientSpy.url, url)
        
    }
    class HttpClientSpy: HttpClient {
        var url: URL?
        
        func post(url: URL) {
            self.url = url
        }
        
    }
    
}
