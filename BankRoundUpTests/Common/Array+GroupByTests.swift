import Quick
import Nimble
import BankRoundUp

final class Array_GroupBySpec: QuickSpec {

    override func spec() {

        describe("Array") {

            describe("groupBy(keySelector:)") {

                context("array of Int and isEven(_:) keySelector") {
                    typealias Element = Int
                    typealias Key = Bool

                    var array: [Element]!
                    var keySelector: ((Element) -> Key)!
                    beforeEach {
                        keySelector = { $0 % 2 == 0 }
                    }

                    context("empty array") {
                        beforeEach {
                            array = []
                        }
                        it("must return empty array of groups") {
                            expect(array.groupBy(keySelector: keySelector)).to(beEmpty())
                        }
                    }

                    context("6 elements array starting with odd element") {
                        beforeEach {
                            array = [1, 4, 6, 5, 2, 3]
                        }
                        it("must return proper array of 2 groups") {
                            let result = array.groupBy(keySelector: keySelector)

                            expect(result).to(haveCount(2))

                            let (firstKey, firstGroup) = result.first!
                            expect(firstKey).to(equal(false))
                            expect(firstGroup).to(equal([1, 5, 3]))

                            let (secondKey, secondGroup) = result.last!
                            expect(secondKey).to(equal(true))
                            expect(secondGroup).to(equal([4, 6, 2]))
                        }
                    }

                    context("6 elements array starting with even element") {
                        beforeEach {
                            array = [4, 1, 5, 6, 2, 3]
                        }
                        it("must return proper array of 2 groups") {
                            let result = array.groupBy(keySelector: keySelector)

                            expect(result).to(haveCount(2))

                            let (firstKey, firstGroup) = result.first!
                            expect(firstKey).to(equal(true))
                            expect(firstGroup).to(equal([4, 6, 2]))

                            let (secondKey, secondGroup) = result.last!
                            expect(secondKey).to(equal(false))
                            expect(secondGroup).to(equal([1, 5, 3]))
                        }
                    }
                }

                context("array of String and firstChar(_:) keySelector") {
                    typealias Element = String
                    typealias Key = String

                    var array: [Element]!
                    var keySelector: ((Element) -> Key)!
                    beforeEach {
                        keySelector = { $0.isEmpty ? "-" : "\($0.first!)" }
                    }

                    context("empty array") {
                        beforeEach {
                            array = []
                        }
                        it("must return empty array of groups") {
                            expect(array.groupBy(keySelector: keySelector)).to(beEmpty())
                        }
                    }

                    context("7 elements array starting with 5 different characters") {
                        beforeEach {
                            array = [
                                "Mary",
                                "Anne",
                                "Hi",
                                "Hello",
                                "Mark",
                                "John",
                                "Ben"
                            ]
                        }
                        it("must return proper array of 5 groups") {
                            let result = array.groupBy(keySelector: keySelector)

                            expect(result).to(haveCount(5))

                            let (firstKey, firstGroup) = result[0]
                            expect(firstKey).to(equal("M"))
                            expect(firstGroup).to(equal(["Mary", "Mark"]))

                            let (secondKey, secondGroup) = result[1]
                            expect(secondKey).to(equal("A"))
                            expect(secondGroup).to(equal(["Anne"]))

                            let (thirdKey, thirdGroup) = result[2]
                            expect(thirdKey).to(equal("H"))
                            expect(thirdGroup).to(equal(["Hi", "Hello"]))

                            let (fourthKey, fourthGroup) = result[3]
                            expect(fourthKey).to(equal("J"))
                            expect(fourthGroup).to(equal(["John"]))

                            let (fifthKey, fifthGroup) = result[4]
                            expect(fifthKey).to(equal("B"))
                            expect(fifthGroup).to(equal(["Ben"]))
                        }
                    }
                }
            }
        }
    }
}
