import Quick
import Nimble
@testable import BankRoundUp

final class TransactionsFetchingGateway_ResponseSpec: QuickSpec {

    override func spec() {

        describe("TransactionsFetchingGateway.Response") {

            describe("from(jsonData:)") {

                var jsonData: Data!

                context("empty json data") {
                    beforeEach {
                        jsonData = Data()
                    }
                    it("must throw exception") {
                        expect {
                            try TransactionsFetchingGateway.Response.from(jsonData)
                            }
                            .to(throwError())
                    }
                }

                context("json data with 2 transactions list") {
                    beforeEach {
                        jsonData = """
                        {
                          \"_embedded\": {
                            \"transactions\": [
                              {
                                \"id\": \"95da7450-3176-433a-866c-a1ba2be65342\",
                                \"currency\": \"GBP\",
                                \"amount\": -28.57,
                                \"direction\": \"OUTBOUND\",
                                \"created\": \"2018-06-09T10:25:02.609Z\",
                                \"narrative\": \"Yorkshire Bank IV\",
                                \"source\": \"MASTER_CARD\",
                                \"balance\": 2265.01
                              },
                              {
                                \"id\": \"6a2a18bc-9c51-403e-b347-46d93aea3aa8\",
                                \"currency\": \"GBP\",
                                \"amount\": -6.72,
                                \"direction\": \"OUTBOUND\",
                                \"created\": \"2018-06-09T10:25:02.440Z\",
                                \"narrative\": \"Mastercard\",
                                \"source\": \"MASTER_CARD\",
                                \"balance\": 2293.58
                              }
                            ]
                          }
                        }
                        """.data(using: .utf8)!
                    }
                    it("must return a 2 element transactions array") {
                        expect(
                            try! TransactionsFetchingGateway.Response
                                .from(jsonData)
                                ._embedded
                                .transactions
                            )
                            .to(haveCount(2))
                    }
                }
            }
        }
    }
}
