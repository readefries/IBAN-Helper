//
//  IBANCreationTests.swift
//  RFIBANHelper_Tests
//
//  Tests for IBAN creation functionality
//

import XCTest
@testable import RFIBANHelper

final class IBANCreationTests: XCTestCase {
    private let validator = IBANValidator()

    override func setUp() async throws {
        try await super.setUp()
        // Ensure country data is loaded
        _ = try await CountryModelsManager.shared.allCountries()
    }

    // MARK: - Legacy IBAN Creation Tests

    func testCreateNLIban() {
        var account = ""
        var bic = ""

        var result = RFIBANHelper.createIBAN(account, bic: bic)
        XCTAssertEqual(result, "", "Creating IBAN with empty account should return empty string")

        account = "417164300"
        result = RFIBANHelper.createIBAN(account, bic: bic)
        XCTAssertEqual(result, "", "Creating IBAN with invalid BIC length should return empty string")

        bic = "ABNANL2A"
        result = RFIBANHelper.createIBAN(account, bic: bic)
        let expectedResult = "NL91ABNA0417164300"
        XCTAssertEqual(result, expectedResult, "Expected result is '\(expectedResult)' not '\(result)'")
    }

    // MARK: - Modern Async IBAN Creation Tests

    func testAsyncIBANCreation() async throws {
        let testCases = [
            (accountNumber: "417164300", bankCode: "ABNA", countryCode: "NL", expectedPrefix: "NL"),
            (accountNumber: "12345698765432", bankCode: "WEST", countryCode: "GB", expectedPrefix: "GB"),
            (accountNumber: "370400440532013000", bankCode: nil, countryCode: "DE", expectedPrefix: "DE")
        ]

        for testCase in testCases {
            let result = await validator.createIBAN(
                accountNumber: testCase.accountNumber,
                bankCode: testCase.bankCode,
                countryCode: testCase.countryCode
            )

            switch result {
            case .success(let iban):
                XCTAssertTrue(iban.hasPrefix(testCase.expectedPrefix), "Created IBAN should start with \(testCase.expectedPrefix)")
                XCTAssertFalse(iban.isEmpty, "Created IBAN should not be empty")

                // Validate the created IBAN
                let validationResult = await validator.validate(iban)
                XCTAssertTrue(validationResult.isSuccess, "Created IBAN should be valid: \(iban)")

            case .failure(let error):
                XCTFail("IBAN creation failed with error: \(error) for test case: \(testCase)")
            }
        }
    }

    func testIBANCreationErrorHandling() async throws {
        let errorTestCases: [(accountNumber: String, countryCode: String, expectedError: IBANError.Type)] = [
            ("", "NL", IBANError.self), // Empty account number
            ("123456789", "XX", IBANError.self), // Invalid country code
            ("123", "ZZ", IBANError.self) // Unsupported country
        ]

        for testCase in errorTestCases {
            let result = await validator.createIBAN(
                accountNumber: testCase.accountNumber,
                countryCode: testCase.countryCode
            )

            switch result {
            case .success(let iban):
                XCTFail("Expected IBAN creation to fail but got: \(iban)")
            case .failure(let error):
                XCTAssertTrue(
                    type(of: error) == testCase.expectedError,
                    "Expected error type \(testCase.expectedError) but got \(type(of: error))"
                )
            }
        }
    }

    // MARK: - BIC-based IBAN Creation Tests

    func testBICBasedCreation() async throws {
        // Test cases with valid BIC codes
        let bicTestCases = [
            (account: "417164300", bic: "ABNANL2A", expectedCountry: "NL"),
            (account: "12345698765432", bic: "WESTGB22", expectedCountry: "GB"),
            (account: "370400440532013000", bic: "COBADEFF", expectedCountry: "DE")
        ]

        for testCase in bicTestCases {
            // Extract country code from BIC (positions 4-5)
            let countryFromBIC = String(testCase.bic[testCase.bic.index(testCase.bic.startIndex, offsetBy: 4)..<testCase.bic.index(testCase.bic.startIndex, offsetBy: 6)])

            let result = await validator.createIBAN(
                accountNumber: testCase.account,
                bankCode: String(testCase.bic.prefix(4)), // Bank code from BIC
                countryCode: countryFromBIC
            )

            switch result {
            case .success(let iban):
                XCTAssertTrue(iban.hasPrefix(testCase.expectedCountry), "IBAN should start with country from BIC")

                let validationResult = await validator.validate(iban)
                XCTAssertTrue(validationResult.isSuccess, "BIC-based IBAN should be valid: \(iban)")

            case .failure(let error):
                XCTFail("BIC-based IBAN creation failed: \(error)")
            }
        }
    }

    // MARK: - Edge Cases

    func testIBANCreationWithSpecialCharacters() async throws {
        // Test account numbers with leading zeros
        let result = await validator.createIBAN(
            accountNumber: "000123456789",
            countryCode: "NL"
        )

        switch result {
        case .success(let iban):
            XCTAssertTrue(iban.hasPrefix("NL"), "IBAN should be created successfully with leading zeros")

            let validationResult = await validator.validate(iban)
            XCTAssertTrue(validationResult.isSuccess, "IBAN with leading zeros should be valid")

        case .failure(let error):
            XCTFail("IBAN creation with leading zeros failed: \(error)")
        }
    }

    func testIBANCreationAccountPadding() async throws {
        // Test that short account numbers are properly padded
        let shortAccount = "123456"
        let result = await validator.createIBAN(
            accountNumber: shortAccount,
            countryCode: "NL"
        )

        switch result {
        case .success(let iban):
            XCTAssertEqual(iban.count, 18, "Dutch IBAN should be 18 characters")

            // The BBAN part should be properly padded
            let bban = String(iban.dropFirst(4))
            XCTAssertTrue(bban.hasPrefix("0"), "Short account should be zero-padded")

        case .failure(let error):
            XCTFail("IBAN creation with short account failed: \(error)")
        }
    }

    // MARK: - Performance Tests

    func testIBANCreationPerformance() async throws {
        let accountNumber = "417164300"
        let countryCode = "NL"

        measure {
            let expectation = XCTestExpectation(description: "IBAN creation performance")

            Task {
                for _ in 0..<100 {
                    _ = await validator.createIBAN(accountNumber: accountNumber, countryCode: countryCode)
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    // MARK: - Legacy vs Modern API Comparison

    func testLegacyVsModernCreation() async throws {
        let account = "417164300"
        let bic = "ABNANL2A"

        // Legacy API
        let legacyResult = RFIBANHelper.createIBAN(account, bic: bic)

        // Modern API equivalent
        let modernResult = await validator.createIBAN(
            accountNumber: account,
            bankCode: String(bic.prefix(4)),
            countryCode: String(bic[bic.index(bic.startIndex, offsetBy: 4)..<bic.index(bic.startIndex, offsetBy: 6)])
        )

        switch modernResult {
        case .success(let modernIBAN):
            XCTAssertEqual(legacyResult, modernIBAN, "Legacy and modern APIs should produce the same result")
        case .failure(let error):
            XCTFail("Modern API failed while legacy succeeded: \(error)")
        }
    }
}