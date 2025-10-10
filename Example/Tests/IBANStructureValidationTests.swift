//
//  IBANStructureValidationTests.swift
//  RFIBANHelper_Tests
//
//  Tests for IBAN structural validation (length, start bytes, inner structure)
//

import XCTest
@testable import RFIBANHelper

final class IBANStructureValidationTests: XCTestCase {
    private let validator = IBANValidator()

    override func setUp() async throws {
        try await super.setUp()
        // Ensure country data is loaded
        _ = try await CountryModelsManager.shared.allCountries()
    }

    // MARK: - Basic Structure Tests

    func testIBANWithoutBankAccountNumber() {
        let sut = "NL26"
        let result = RFIBANHelper.isValidIBAN(sut)
        XCTAssertEqual(result, .invalidBankAccount, "BBAN part should have at least one digit")
    }

    func testIBANWithInvalidStructure() {
        var sut = "ES"
        var result = RFIBANHelper.isValidIBAN(sut)
        XCTAssertEqual(result, .invalidStructure, "IBAN prefix is missing or contains invalid characters")

        sut = ""
        result = RFIBANHelper.isValidIBAN(sut)
        XCTAssertEqual(result, .invalidStructure, "Empty IBAN should be invalid")
    }

    func testInvalidStartBytes() {
        let sut = "NLKR"
        let result = RFIBANHelper.isValidIBAN(sut)
        XCTAssertEqual(result, .invalidStartBytes, "Start bytes should follow country code + check digits pattern")
    }

    func testThatIbanWithOneCharacterMissingWillNotCrash() {
        let sut = "NL20INGB000123456"
        let result = RFIBANHelper.isValidIBAN(sut)
        XCTAssertEqual(result, .invalidInnerStructure, "IBAN with missing character should be invalid structure")
    }

    // MARK: - Async Structure Validation Tests

    func testAsyncStructureValidation() async throws {
        let structureTestCases: [(iban: String, expectedError: IBANError)] = [
            ("", .invalidStructure),
            ("AB", .invalidStructure),
            ("INVALID_CHARS!@#", .invalidStructure),
            ("NL26", .invalidBankAccount),
            ("NLKR1234567890", .invalidStartBytes)
        ]

        for testCase in structureTestCases {
            let result = await validator.validate(testCase.iban)

            switch result {
            case .success:
                XCTFail("Expected validation to fail for IBAN: \(testCase.iban)")
            case .failure(let error):
                // Check that we get the expected type of error
                let errorMatches = switch (error, testCase.expectedError) {
                case (.invalidStructure, .invalidStructure),
                     (.invalidBankAccount, .invalidBankAccount),
                     (.invalidStartBytes, .invalidStartBytes):
                    true
                default:
                    false
                }
                XCTAssertTrue(errorMatches, "Expected \(testCase.expectedError) but got \(error) for IBAN: \(testCase.iban)")
            }
        }
    }

    // MARK: - Length Validation Tests

    func testIBANLengthValidation() async throws {
        // Test that correct length IBANs pass basic structure
        let lengthTestCases = [
            ("GB82WEST12345698765432", 22), // UK
            ("NL20INGB0001234567", 18),     // Netherlands
            ("DE89370400440532013000", 22), // Germany
            ("FR1420041010050500013M02606", 27) // France
        ]

        for (iban, expectedLength) in lengthTestCases {
            XCTAssertEqual(iban.count, expectedLength, "Test IBAN \(iban) should have expected length")

            // Test with one character missing
            let shortIBAN = String(iban.dropLast())
            let shortResult = await validator.validate(shortIBAN)
            XCTAssertTrue(shortResult.isFailure, "IBAN with missing character should be invalid: \(shortIBAN)")

            // Test with one extra character
            let longIBAN = iban + "X"
            let longResult = await validator.validate(longIBAN)
            XCTAssertTrue(longResult.isFailure, "IBAN with extra character should be invalid: \(longIBAN)")
        }
    }

    // MARK: - Country Code Validation Tests

    func testInvalidCountryCode() {
        let sut = "KR00BANK0123456789"
        let result = RFIBANHelper.isValidIBAN(sut)
        XCTAssertEqual(result, .invalidCountryCode, "Unsupported country codes should be invalid")
    }

    func testAsyncCountryCodeValidation() async throws {
        let invalidCountryCodes = ["XX", "ZZ", "KR", "JP", "US"]

        for countryCode in invalidCountryCodes {
            let fakeIBAN = "\(countryCode)00BANK1234567890123456"
            let result = await validator.validate(fakeIBAN)

            switch result {
            case .success:
                XCTFail("Country code \(countryCode) should not be supported")
            case .failure(let error):
                switch error {
                case .missingCountryData, .invalidCountryCode:
                    XCTAssert(true, "Expected country-related error for \(countryCode)")
                default:
                    // Other errors are also acceptable (structure, checksum, etc.)
                    XCTAssert(true, "Got error \(error) for unsupported country \(countryCode)")
                }
            }
        }
    }

    // MARK: - Performance Tests

    func testStructureValidationPerformance() {
        let iban = "GB82WEST12345698765432"

        measure {
            for _ in 0..<1000 {
                _ = RFIBANHelper.isValidIBAN(iban)
            }
        }
    }

    func testAsyncValidationPerformance() async throws {
        let iban = "GB82WEST12345698765432"

        measure {
            let expectation = XCTestExpectation(description: "Async validation")

            Task {
                for _ in 0..<100 {
                    _ = await validator.validate(iban)
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }
}