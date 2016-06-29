
import UIKit
import XCTest

import RFIBANHelper

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

  func testInvalidIntValueForString()
  {
    let sut = ")(*&(*&%&^$"

    let result = RFIBANHelper.intValueForString(sut)

    XCTAssert(result == "", String(format: "the result should be an empty string, not %@", result))
  }

  func testCreateNLIban()
  {
    var account = ""
    var bic = ""

    var result = RFIBANHelper.createIBAN(account, bic:bic)

    XCTAssert(result == "", "Creating an IBAN whilst providing an empty account should return an empty string")

    account = "417164300"

    result = RFIBANHelper.createIBAN(account, bic:bic)

    XCTAssert(result == "", "Creating an IBAN whilst providing a bic with a lengthe different then 8 or 11")

    bic = "ABNANL2A"

    result = RFIBANHelper.createIBAN(account, bic:bic)

    let expectedResult = "NL91ABNA0417164300"

    XCTAssert(result == expectedResult, String(format:"The expected resultis '%@' not '%@'", expectedResult, result))
  }

  func testInvalidStartBytes()
  {
    let sut = "NLKR"

    let result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .InvalidStartBytes, String(format: "%d should be .InvalidStartBytes", result.rawValue))
  }

  func testValidDecimalsAndCharactersFormat()
  {
    let sut = "0124556789ABCde"
    let format = "A15"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssert(result == true, String(format: "%@ should be validated with format %@ successfuly", sut, format))
  }

  func testValidDecimalAndUppercaseCharacters()
  {
    let sut = "0123456789ABCDEFGHIJ"
    let format = "B20"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssert(result == true, String(format: "%@ should be validated with format %@ successfuly", sut, format))
    
  }

  func testValidCharacters()
  {
    let sut = "ABCdef"
    let format = "C06"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssert(result == true, String(format: "%@ should be validated with format %@ successfuly", sut, format))
    
  }

  func testValidDecimals()
  {
    let sut = "1234567890"
    let format = "F10"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssert(result == true, String(format: "%@ should be validated with format %@ successfuly", sut, format))
    
  }

  func testValidLowercaseCharacters()
  {
    let sut = "abcdefgh"
    let format = "L08"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssert(result == true, String(format: "%@ should be validated with format %@ successfuly", sut, format))
    
  }

  func testValidUppercaseCharacters()
  {
    let sut = "ABCDEFGH"
    let format = "U08"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssert(result == true, String(format: "%@ should be validated with format %@ successfuly", sut, format))

  }

  func testValidDecimalsAndLowercaseCharacters()
  {
    let sut = "0123abcd"
    let format = "W08"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssert(result == true, String(format: "%@ should be validated with format %@ successfuly", sut, format))

  }

  func testInvalidFormat()
  {
    let sut = "0123456789"
    let format = "X10"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssert(result == false, "")
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

  func testInvalidCharacters()
  {
    let sut = "()$("

    let result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .InvalidCharacters, String(format: "%@ should contain invalid chatacter IBAN, yet the result is %@", sut, result.rawValue))
  }

  func testInvalidCountryCode()
  {
    let sut = "KR00BANK0123456789"

    let result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .InvalidCountryCode, String(format: "%@ should result in invalid country, yet the result is %@", sut, result.rawValue))
  }

  func testISO7064_Mod_97_10()
  {
    let sut = "182316110001234567232100"

    let result = ISO7064.MOD97_10(sut)
    XCTAssert(result == 78, String(format: "182316110001234567232100 mod 97 should be 78, not %d", result))
  }

  func testISO7064_Mod_97_10_WithInvalidCharacters()
  {
    let sut = "INVALID CHARACTERS"

    let result = ISO7064.MOD97_10(sut)
    XCTAssert(result == NSNotFound, String(format: "%@ should return NSNotFound, not %d", sut, result))
  }
}
