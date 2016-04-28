import UIKit
import XCTest

class Tests: XCTestCase {

  override func setUp()
  {
    super.setUp()
  }

  override func tearDown()
  {
    super.tearDown()
  }

  func testReplacingCharactersWithDigits()
  {
    let sut = "GB82WEST12345698765432"

    let result = RFIBANHelper.intValueForString(sut)

    XCTAssert(result == "1611823214282912345698765432", String(format: "the result should be 11823214282912345698765432, not %@", result))
  }

  func testValidityOfGBIban()
  {
    let sut = "GB82WEST12345698765432"

    let result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .ValidIban, String(format: "%@ should be a valid IBAN, yet the result is %@", sut, result.rawValue))
  }

  func testValidityOfNLIban()
  {
    let sut = "NL20INGB0001234567"

    let result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .ValidIban, String(format: "%@ should be a valid IBAN, yet the result is %@", sut, result.rawValue))
  }

  func testValidityOfHUIban()
  {
    let sut = "HU42117730161111101800000000"

    let result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .ValidIban, String(format: "%@ should be a valid IBAN, yet the result is %@", sut, result.rawValue))
  }

  func testISO7064_Mod_97_10()
  {
    let sut = "182316110001234567232100"

    let result = ISO7064.MOD97_10(sut)
    XCTAssert(result == 78, String(format: "182316110001234567232100 mod 97 should be 78, not %d", result))
  }

}
