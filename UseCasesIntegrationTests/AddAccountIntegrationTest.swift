import XCTest
import Data
import Infra
import Domain
 
class AddAccountIntegrationTest: XCTestCase {

    func test_add_account() {
        let alamofireApapter = AlamofireAdapter()
        let url = URL(string: "https://clean-node-api.herokuapp.com/api/signup")!
        let sut = RemoteAddAccount(url: url, httpClien: alamofireApapter)
        let addAccountModel = AddAccountModel(name: "name", email: "name@name", password: "secret", passwordConfirmation: "secret")
        let exp = expectation(description: "waiting")
        sut.add(addAccountModel: addAccountModel) { result in
            switch result {
            case .failure: XCTFail("Expected sucess got \(result) insted")
            case.success(let account):
                XCTAssertNotNil(account.id)
                XCTAssertEqual(account.name, addAccountModel.name)
                XCTAssertEqual(account.email, addAccountModel.email)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }


}
