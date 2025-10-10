//
//  ModernFeaturesTests.swift
//  RFIBANHelper_Tests
//
//  Tests for modern Swift features like property wrappers and SwiftUI integration
//

import XCTest
@testable import RFIBANHelper

#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(Combine)
import Combine
#endif

final class ModernFeaturesTests: XCTestCase {

    // MARK: - Property Wrapper Tests

    func testValidatedIBANPropertyWrapper() async {
        @ValidatedIBAN var iban = ""

        // Test setting valid IBAN
        iban = "GB82WEST12345698765432"

        // Give async validation time to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Property wrapper should have stored the valid IBAN
        XCTAssertEqual(iban, "GB82WEST12345698765432", "Property wrapper should store valid IBAN")
    }

    func testFormattedIBANPropertyWrapper() {
        @FormattedIBAN var iban = "GB82WEST12345698765432"

        // Should return formatted version
        XCTAssertEqual(iban, "GB82 WEST 1234 5698 7654 32", "Property wrapper should format IBAN")

        // Projected value should return clean version
        XCTAssertEqual($iban, "GB82WEST12345698765432", "Projected value should return unformatted IBAN")

        // Test setting formatted input
        iban = "NL91 ABNA 0417 1643 00"
        XCTAssertEqual($iban, "NL91ABNA0417164300", "Should clean formatted input")
    }

    // MARK: - SwiftUI Integration Tests

    #if canImport(SwiftUI)
    @available(iOS 13.0, macOS 10.15, *)
    func testIBANValidationModel() async {
        let model = IBANValidationModel()

        // Test valid IBAN
        model.iban = "GB82WEST12345698765432"

        // Give validation time to complete
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        await MainActor.run {
            XCTAssertTrue(model.isValid, "Valid IBAN should be marked as valid")
            XCTAssertNil(model.validationError, "Valid IBAN should have no error")
            XCTAssertEqual(model.formattedIBAN, "GB82 WEST 1234 5698 7654 32", "Should format valid IBAN")
        }

        // Test invalid IBAN
        await MainActor.run {
            model.iban = "INVALID"
        }

        // Give validation time to complete
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        await MainActor.run {
            XCTAssertFalse(model.isValid, "Invalid IBAN should be marked as invalid")
            XCTAssertNotNil(model.validationError, "Invalid IBAN should have error")
            XCTAssertEqual(model.formattedIBAN, "", "Invalid IBAN should not be formatted")
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func testIBANValidationModelHelpers() {
        let model = IBANValidationModel()
        model.iban = "GB82WEST12345698765432"

        let formatted = model.format()
        XCTAssertEqual(formatted, "GB82 WEST 1234 5698 7654 32", "Format method should work")

        let cleaned = model.clean()
        XCTAssertEqual(cleaned, "GB82WEST12345698765432", "Clean method should work")
    }
    #endif

    // MARK: - Combine Integration Tests

    #if canImport(Combine)
    @available(iOS 13.0, macOS 10.15, *)
    func testCombineValidation() async throws {
        let validator = IBANValidator()
        let validIBAN = "GB82WEST12345698765432"

        let publisher = validator.validatePublisher(validIBAN)
        let result = try await publisher.first().value

        switch result {
        case .success:
            XCTAssert(true, "Combine validation should succeed for valid IBAN")
        case .failure(let error):
            XCTFail("Combine validation failed: \(error)")
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func testCombineIBANCreation() async throws {
        let validator = IBANValidator()

        let publisher = validator.createIBANPublisher(
            accountNumber: "417164300",
            countryCode: "NL"
        )

        let result = try await publisher.first().value

        switch result {
        case .success(let iban):
            XCTAssertTrue(iban.hasPrefix("NL"), "Created IBAN should start with NL")
        case .failure(let error):
            XCTFail("Combine IBAN creation failed: \(error)")
        }
    }
    #endif

    // MARK: - Error Handling Tests

    func testIBANErrorLocalization() {
        let errors: [IBANError] = [
            .invalidJSON,
            .missingCountryData("XX"),
            .invalidFormat,
            .checksumError,
            .invalidStartBytes,
            .invalidInnerStructure,
            .invalidLength,
            .invalidCountryCode,
            .invalidBankAccount,
            .invalidStructure
        ]

        for error in errors {
            let description = error.localizedDescription
            XCTAssertFalse(description.isEmpty, "Error should have localized description: \(error)")
            XCTAssertNotEqual(description, error.localizedDescription, "Should not be the default description")
        }
    }

    func testResultExtensions() {
        let successResult: Result<String, IBANError> = .success("test")
        let failureResult: Result<String, IBANError> = .failure(.invalidFormat)

        XCTAssertTrue(successResult.isSuccess, "Success result should be marked as success")
        XCTAssertFalse(failureResult.isSuccess, "Failure result should not be marked as success")
    }

    // MARK: - Format Enum Tests

    func testIBANFormatEnum() {
        let formats = IBANFormat.allCases

        XCTAssertFalse(formats.isEmpty, "Should have format cases")

        for format in formats {
            XCTAssertNotNil(format.regex, "Format should have valid regex: \(format)")
            XCTAssertFalse(format.pattern.isEmpty, "Format should have pattern: \(format)")
        }
    }

    func testIBANFormatValidation() {
        let testCases: [(format: IBANFormat, validInput: String, invalidInput: String)] = [
            (.alphanumeric, "ABC123", "ABC-123"),
            (.alphanumericUppercase, "ABC123", "abc123"),
            (.alphabetic, "ABCdef", "ABC123"),
            (.numeric, "123456", "12A456"),
            (.lowercaseAlpha, "abcdef", "ABCdef"),
            (.uppercaseAlpha, "ABCDEF", "abcdef"),
            (.alphanumericLowercase, "abc123", "ABC123")
        ]

        for testCase in testCases {
            guard let regex = testCase.format.regex else {
                XCTFail("Format should have regex: \(testCase.format)")
                continue
            }

            // Test valid input
            let validRange = NSRange(location: 0, length: testCase.validInput.count)
            let validMatch = regex.firstMatch(in: testCase.validInput, options: [], range: validRange)
            XCTAssertNotNil(validMatch, "Format \(testCase.format) should match: \(testCase.validInput)")

            // Test invalid input
            let invalidRange = NSRange(location: 0, length: testCase.invalidInput.count)
            let invalidMatch = regex.firstMatch(in: testCase.invalidInput, options: [], range: invalidRange)
            XCTAssertNil(invalidMatch, "Format \(testCase.format) should not match: \(testCase.invalidInput)")
        }
    }

    // MARK: - Performance Tests

    func testPropertyWrapperPerformance() {
        @FormattedIBAN var iban = ""

        measure {
            for _ in 0..<1000 {
                iban = "GB82WEST12345698765432"
                _ = iban // Read formatted value
                _ = $iban // Read unformatted value
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func testSwiftUIModelPerformance() async {
        let model = IBANValidationModel()

        measure {
            let expectation = XCTestExpectation(description: "SwiftUI model performance")

            Task {
                for i in 0..<100 {
                    await MainActor.run {
                        model.iban = i % 2 == 0 ? "GB82WEST12345698765432" : "NL91ABNA0417164300"
                    }
                    try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 10.0)
        }
    }
}

// MARK: - Helper Extensions for Tests

@available(iOS 13.0, macOS 10.15, *)
extension Publisher {
    func first() -> Future<Output, Failure> {
        return Future { promise in
            var cancellable: AnyCancellable?
            cancellable = self.first().sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                    cancellable?.cancel()
                },
                receiveValue: { value in
                    promise(.success(value))
                    cancellable?.cancel()
                }
            )
        }
    }
}