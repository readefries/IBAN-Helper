import UIKit
import XCTest

@testable import RFIBANHelper

class Tests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testReplacingCharactersWithDigits() {
    let sut = "GB82WEST12345698765432"

    let result = RFIBANHelper.intValueForString(sut)

    XCTAssert(result == "1611823214282912345698765432", "the result should be 11823214282912345698765432, not \(result)")
  }

  func testInvalidIntValueForString() {
    let sut = ")(*&(*&%&^$"

    let result = RFIBANHelper.intValueForString(sut)

    XCTAssert(result == "", "the result should be an empty string, not \(result)")
  }

  func testIBANWithoutBankAccountNumber() {
    let sut = "NL26"
    
    let result = RFIBANHelper.isValidIBAN(sut)
    
    XCTAssert(result == .invalidBankAccount, "The BBAN part of the IBAN should have at least one digit")
  }

  func testIBANWithInvalidStructure() {
    var sut = "ES"

    var result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .invalidStructure, "The IBAN prefix is missing, or the IBAN contains invalid characters")

    sut = ""

    result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .invalidStructure, "The IBAN prefix is missing, or the IBAN contains invalid characters")
  }
  
  func testCreateNLIban() {
    var account = ""
    var bic = ""

    var result = RFIBANHelper.createIBAN(account, bic: bic)

    XCTAssert(result == "", "Creating an IBAN whilst providing an empty account should return an empty string")

    account = "417164300"

    result = RFIBANHelper.createIBAN(account, bic: bic)

    XCTAssert(result == "", "Creating an IBAN whilst providing a bic with a lengthe different then 8 or 11")

    bic = "ABNANL2A"

    result = RFIBANHelper.createIBAN(account, bic: bic)

    let expectedResult = "NL91ABNA0417164300"

    XCTAssert(result == expectedResult, "The expected resultis '\(expectedResult)@' not '\(result)'")
  }

  func testInvalidStartBytes() {
    let sut = "NLKR"

    let result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .invalidStartBytes, "\(result.rawValue) should be .InvalidStartBytes")
  }

  func testValidDecimalsAndCharactersFormat() {
    let sut = "0124556789ABCde"
    let format = "A15"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfuly")
  }

  func testValidDecimalAndUppercaseCharacters() {
    let sut = "0123456789ABCDEFGHIJ"
    let format = "B20"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfuly")
  }

  func testValidCharacters() {
    let sut = "ABCdef"
    let format = "C06"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfuly")
  }

  func testValidDecimals() {
    let sut = "1234567890"
    let format = "F10"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfuly")
  }

  func testValidLowercaseCharacters() {
    let sut = "abcdefgh"
    let format = "L08"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfuly")
  }

  func testValidUppercaseCharacters() {
    let sut = "ABCDEFGH"
    let format = "U08"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfuly")
  }

  func testValidDecimalsAndLowercaseCharacters() {
    let sut = "0123abcd"
    let format = "W08"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfuly")
  }

  func testInvalidFormat() {
    let sut = "0123456789"
    let format = "X10"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    XCTAssertFalse(result)
  }

  func testValidityOfGBIban() {
    let sut = "GB82WEST12345698765432"

    let result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
  }

  func testValidityOfNLIban() {
    let sut = "NL20INGB0001234567"

    let result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
  }

  func testValidityOfHUIban() {
    let sut = "HU42117730161111101800000000"

    let result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
  }

  func testInvalidCountryCode() {
    let sut = "KR00BANK0123456789"

    let result = RFIBANHelper.isValidIBAN(sut)

    XCTAssert(result == .invalidCountryCode, "\(sut) should result in invalid country, yet the result is \(result)")
  }

  func testISO7064_Mod_97_10() {
    let sut = "182316110001234567232100"

    let result = ISO7064.MOD97_10(sut)
    XCTAssert(result == 78, "182316110001234567232100 mod 97 should be 78, not \(result)")
  }

  func testISO7064_Mod_97_10_WithInvalidCharacters() {
    let sut = "INVALID CHARACTERS"

    let result = ISO7064.MOD97_10(sut)
    XCTAssert(result == NSNotFound, "\(sut) should return NSNotFound, not \(result)")
  }
    
  func testThatIbanWithOneCharacteMissingWillNotCrash() {
    let sut = "NL20INGB000123456"
    
    let result = RFIBANHelper.isValidIBAN(sut)
    
    XCTAssert(result == .invalidInnerStructure, "\(sut) should be an invalid structure, yet the result is \(result)")
  }
}
