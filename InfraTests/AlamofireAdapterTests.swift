import XCTest
import Alamofire
    
class AlamofireAdapter {
    private let session: Session
    
    init(session: Session = .default) {
        self.session = session
    }
    
    func post(to url: URL, with data: Data?) {
        let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
        session.request(url, method: .post, parameters: json, encoding: JSONEncoding.default).resume()
    }
}

class AlamofireAdapterTests: XCTestCase {
    func teste_post_should_make_request_with_valid_url_and_method() {
        let url =  makeUrl()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = Session(configuration: configuration)
        let sut = AlamofireAdapter(session: session)
        sut.post(to: url, with: makeValidData())
        let exp = expectation(description: "waiting")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(url, request.url)
            XCTAssertEqual("POST", request.httpMethod)
            XCTAssertNotNil(request.httpBodyStream)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}

class URLProtocolStub: URLProtocol {
    static var completion: ((URLRequest) -> Void)?
    static func observeRequest(completion: @escaping (URLRequest) -> Void) {
        URLProtocolStub.completion = completion
    }
    
    override open class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    override func startLoading() {
        URLProtocolStub.completion?(request)
    }
    override func stopLoading() {}
}

