import Foundation
import Testing

@testable import RFIBANHelper

@Test func testReplacingCharactersWithDigits() async throws {
    let sut = "GB82WEST12345698765432"

    let result = RFIBANHelper.intValueForString(sut)

    #expect(result == "1611823214282912345698765432", "the result should be 11823214282912345698765432, not \(result)")
  }

  @Test func testInvalidIntValueForString() async throws {
    let sut = ")(*&(*&%&^$"

    let result = RFIBANHelper.intValueForString(sut)

    #expect(result == "", "the result should be an empty string, not \(result)")
  }

  @Test func testIBANWithoutBankAccountNumber() async throws {
    let sut = "NL26"
    
    let result = RFIBANHelper.isValidIBAN(sut)
    
    #expect(result == .invalidBankAccount, "The BBAN part of the IBAN should have at least one digit")
  }

  @Test func testIBANWithInvalidStructure() async throws {
    var sut = "ES"

    var result = RFIBANHelper.isValidIBAN(sut)

    #expect(result == .invalidStructure, "The IBAN prefix is missing, or the IBAN contains invalid characters")

    sut = ""

    result = RFIBANHelper.isValidIBAN(sut)

    #expect(result == .invalidStructure, "The IBAN prefix is missing, or the IBAN contains invalid characters")
  }
  
  @Test func testCreateNLIban() async throws {
    var account = ""
    var bic = ""

    var result = RFIBANHelper.createIBAN(account, bic: bic)

    #expect(result == "", "Creating an IBAN whilst providing an empty account should return an empty string")

    account = "417164300"

    result = RFIBANHelper.createIBAN(account, bic: bic)

    #expect(result == "", "Creating an IBAN whilst providing a bic with a lengthe different then 8 or 11")

    bic = "ABNANL2A"

    result = RFIBANHelper.createIBAN(account, bic: bic)

    let expectedResult = "NL91ABNA0417164300"

    #expect(result == expectedResult, "The expected resultis '\(expectedResult)@' not '\(result)'")
  }

  @Test func testInvalidStartBytes() async throws {
    let sut = "NLKR"

    let result = RFIBANHelper.isValidIBAN(sut)

    #expect(result == .invalidStartBytes, "\(result.rawValue) should be .InvalidStartBytes")
  }

  @Test func testValidDecimalsAndCharactersFormat() async throws {
    let sut = "0124556789ABCde"
    let format = "A15"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    #expect(result, "\(sut) should be validated with format \(format) successfuly")
  }

  @Test func testValidDecimalAndUppercaseCharacters() async throws {
    let sut = "0123456789ABCDEFGHIJ"
    let format = "B20"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    #expect(result, "\(sut) should be validated with format \(format) successfuly")
  }

  @Test func testValidCharacters() async throws {
    let sut = "ABCdef"
    let format = "C06"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    #expect(result, "\(sut) should be validated with format \(format) successfuly")
  }

  @Test func testValidDecimals() async throws {
    let sut = "1234567890"
    let format = "F10"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    #expect(result, "\(sut) should be validated with format \(format) successfuly")
  }

  @Test func testValidLowercaseCharacters() async throws {
    let sut = "abcdefgh"
    let format = "L08"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    #expect(result, "\(sut) should be validated with format \(format) successfuly")
  }

  @Test func testValidUppercaseCharacters() async throws {
    let sut = "ABCDEFGH"
    let format = "U08"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    #expect(result, "\(sut) should be validated with format \(format) successfuly")
  }

  @Test func testValidDecimalsAndLowercaseCharacters() async throws {
    let sut = "0123abcd"
    let format = "W08"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    #expect(result, "\(sut) should be validated with format \(format) successfuly")
  }

  @Test func testInvalidFormat() async throws {
    let sut = "0123456789"
    let format = "X10"

    let result = RFIBANHelper.isStringConformFormat(sut, format:format)

    #expect(!result)
  }

  @Test func testValidityOfGBIban() async throws {
    let sut = "GB82WEST12345698765432"

    let result = RFIBANHelper.isValidIBAN(sut)

    #expect(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
  }

  @Test func testValidityOfNLIban() async throws {
    let sut = "NL20INGB0001234567"

    let result = RFIBANHelper.isValidIBAN(sut)

    #expect(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
  }

  @Test func testValidityOfHUIban() async throws {
    let sut = "HU42117730161111101800000000"

    let result = RFIBANHelper.isValidIBAN(sut)

    #expect(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
  }

  @Test func testInvalidCountryCode() async throws {
    let sut = "KR00BANK0123456789"

    let result = RFIBANHelper.isValidIBAN(sut)

    #expect(result == .invalidCountryCode, "\(sut) should result in invalid country, yet the result is \(result)")
  }

  @Test func testISO7064_Mod_97_10() async throws {
    let sut = "182316110001234567232100"

    let result = ISO7064.MOD97_10(sut)
    #expect(result == 78, "182316110001234567232100 mod 97 should be 78, not \(result)")
  }

  @Test func testISO7064_Mod_97_10_WithInvalidCharacters() async throws {
    let sut = "INVALID CHARACTERS"

    let result = ISO7064.MOD97_10(sut)
    #expect(result == NSNotFound, "\(sut) should return NSNotFound, not \(result)")
  }
    
  @Test func testThatIbanWithOneCharacteMissingWillNotCrash() async throws {
    let sut = "NL20INGB000123456"
    
    let result = RFIBANHelper.isValidIBAN(sut)
    
    #expect(result == .invalidInnerStructure, "\(sut) should be an invalid structure, yet the result is \(result)")
  }
