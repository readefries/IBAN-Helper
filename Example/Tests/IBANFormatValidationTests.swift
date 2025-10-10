//
//  IBANFormatValidationTests.swift
//  RFIBANHelper_Tests
//
//  Tests for IBAN format validation and string processing
//

import XCTest
@testable import RFIBANHelper

final class IBANFormatValidationTests: XCTestCase {

    // MARK: - Character Conversion Tests

    func testReplacingCharactersWithDigits() {
        let sut = "GB82WEST12345698765432"
        let result = RFIBANHelper.intValueForString(sut)
        XCTAssertEqual(result, "1611823214282912345698765432", "Character replacement should convert letters to numbers correctly")
    }

    func testInvalidIntValueForString() {
        let sut = ")(*&(*&%&^$"
        let result = RFIBANHelper.intValueForString(sut)
        XCTAssertEqual(result, "", "Invalid characters should return empty string")
    }

    // MARK: - Format Pattern Tests

    func testValidDecimalsAndCharactersFormat() {
        let sut = "0124556789ABCde"
        let format = "A15"
        let result = RFIBANHelper.isStringConformFormat(sut, format: format)
        XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfully")
    }

    func testValidDecimalAndUppercaseCharacters() {
        let sut = "0123456789ABCDEFGHIJ"
        let format = "B20"
        let result = RFIBANHelper.isStringConformFormat(sut, format: format)
        XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfully")
    }

    func testValidCharacters() {
        let sut = "ABCdef"
        let format = "C06"
        let result = RFIBANHelper.isStringConformFormat(sut, format: format)
        XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfully")
    }

    func testValidDecimals() {
        let sut = "1234567890"
        let format = "F10"
        let result = RFIBANHelper.isStringConformFormat(sut, format: format)
        XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfully")
    }

    func testValidLowercaseCharacters() {
        let sut = "abcdefgh"
        let format = "L08"
        let result = RFIBANHelper.isStringConformFormat(sut, format: format)
        XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfully")
    }

    func testValidUppercaseCharacters() {
        let sut = "ABCDEFGH"
        let format = "U08"
        let result = RFIBANHelper.isStringConformFormat(sut, format: format)
        XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfully")
    }

    func testValidDecimalsAndLowercaseCharacters() {
        let sut = "0123abcd"
        let format = "W08"
        let result = RFIBANHelper.isStringConformFormat(sut, format: format)
        XCTAssertTrue(result, "\(sut) should be validated with format \(format) successfully")
    }

    func testInvalidFormat() {
        let sut = "0123456789"
        let format = "X10"
        let result = RFIBANHelper.isStringConformFormat(sut, format: format)
        XCTAssertFalse(result, "Invalid format code should return false")
    }

    // MARK: - Modern Format Enum Tests

    func testIBANFormatEnumPatterns() {
        let testCases: [(format: IBANFormat, validString: String, invalidString: String)] = [
            (.alphanumeric, "ABC123", "ABC-123"),
            (.alphanumericUppercase, "ABC123", "abc123"),
            (.alphabetic, "ABCdef", "ABC123"),
            (.numeric, "123456", "12A456"),
            (.lowercaseAlpha, "abcdef", "ABCdef"),
            (.uppercaseAlpha, "ABCDEF", "abcdef"),
            (.alphanumericLowercase, "abc123", "ABC123")
        ]

        for testCase in testCases {
            // Test valid string
            let validRange = NSRange(location: 0, length: testCase.validString.count)
            let validMatch = testCase.format.regex?.firstMatch(in: testCase.validString, options: [], range: validRange)
            XCTAssertNotNil(validMatch, "Format \(testCase.format) should match valid string: \(testCase.validString)")

            // Test invalid string
            let invalidRange = NSRange(location: 0, length: testCase.invalidString.count)
            let invalidMatch = testCase.format.regex?.firstMatch(in: testCase.invalidString, options: [], range: invalidRange)
            XCTAssertNil(invalidMatch, "Format \(testCase.format) should not match invalid string: \(testCase.invalidString)")
        }
    }

    // MARK: - IBAN Formatting Tests

    func testIBANFormatting() {
        let validator = IBANValidator()
        let unformattedIBAN = "GB82WEST12345698765432"
        let formattedIBAN = validator.format(unformattedIBAN)

        XCTAssertEqual(formattedIBAN, "GB82 WEST 1234 5698 7654 32", "IBAN should be formatted with spaces every 4 characters")

        let cleanedIBAN = validator.removeFormatting(formattedIBAN)
        XCTAssertEqual(cleanedIBAN, unformattedIBAN, "Formatting should be reversible")
    }

    func testFormattedIBANPropertyWrapper() {
        @FormattedIBAN var iban = "GB82WEST12345698765432"

        // Should return formatted version
        XCTAssertEqual(iban, "GB82 WEST 1234 5698 7654 32", "Property wrapper should format IBAN")

        // Projected value should return clean version
        XCTAssertEqual($iban, "GB82WEST12345698765432", "Projected value should return unformatted IBAN")
    }
}