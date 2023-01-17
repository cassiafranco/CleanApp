import XCTest
import Alamofire
import Data
    
class AlamofireAdapter {
    private let session: Session
    
    init(session: Session = .default) {
        self.session = session
    }
    
    func post(to url: URL, with data: Data?) {
        session.request(url, method: .post, parameters: data?.toJSon(), encoding: JSONEncoding.default).resume()
    }
}

class AlamofireAdapterTests: XCTestCase {
    func teste_post_should_make_request_with_valid_url_and_method() {
        let url =  makeUrl()
        testeRequestFor(url: url, data: makeValidData()) { request in
            XCTAssertEqual(url, request.url)
            XCTAssertEqual("POST", request.httpMethod)
            XCTAssertNotNil(request.httpBodyStream)
        }
    }
    func teste_post_should_make_request_with_no_data() {
        testeRequestFor(data: nil) { request in
            XCTAssertNil(request.httpBodyStream)
        }
    }
}
extension AlamofireAdapterTests {
    func makeSut(file: StaticString = #file, line: UInt = #line) -> AlamofireAdapter {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = Session(configuration: configuration)
        let sut = AlamofireAdapter(session: session)
        checkMemoryLeak(for: sut, file: file, line: line)
        return sut
    }
    func testeRequestFor(url: URL = makeUrl(), data: Data?, action: @escaping (URLRequest) -> Void) {
        let sut = makeSut()
        sut.post(to:url, with: data)
        let exp = expectation(description: "waiting")
        URLProtocolStub.observeRequest { request in
           action(request)
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

