//
//  BrazilianIBANInvestigationTests.swift
//  RFIBANHelper_Tests
//
//  Investigation of Brazilian IBAN validation issue
//

import XCTest
@testable import RFIBANHelper

final class BrazilianIBANInvestigationTests: XCTestCase {
    private let validator = IBANValidator()

    override func setUp() async throws {
        try await super.setUp()
        // Ensure country data is loaded
        _ = try await CountryModelsManager.shared.allCountries()
    }

    func testBrazilianIBANValidation() {
        let brazilianIBAN = "BR0200000000010670000117668C1"

        print("\n=== Testing Brazilian IBAN: \(brazilianIBAN) ===")
        print("Length: \(brazilianIBAN.count)")

        // Test with legacy API
        let legacyResult = RFIBANHelper.isValidIBAN(brazilianIBAN)
        print("Legacy API result: \(legacyResult)")

        // Test individual components
        let countryCode = String(brazilianIBAN.prefix(2))
        print("Country code: \(countryCode)")

        let checkDigits = String(brazilianIBAN[brazilianIBAN.index(brazilianIBAN.startIndex, offsetBy: 2)..<brazilianIBAN.index(brazilianIBAN.startIndex, offsetBy: 4)])
        print("Check digits: \(checkDigits)")

        let bban = String(brazilianIBAN.dropFirst(4))
        print("BBAN: \(bban)")
        print("BBAN length: \(bban.count)")

        if legacyResult != .validIban {
            print("❌ IBAN FAILED VALIDATION: \(legacyResult)")
            print("Reason: \(legacyResult)")
        } else {
            print("✅ IBAN PASSED VALIDATION")
        }

        XCTAssertEqual(legacyResult, .validIban, "Brazilian IBAN should be valid according to legacy API")
    }

    func testAsyncBrazilianIBANValidation() async {
        let brazilianIBAN = "BR0200000000010670000117668C1"

        // Test with modern async API
        let modernResult = await validator.validate(brazilianIBAN)

        switch modernResult {
        case .success:
            print("Modern API: Brazilian IBAN is valid")
            XCTAssert(true, "Brazilian IBAN should be valid")
        case .failure(let error):
            print("Modern API failed with error: \(error)")
            print("Error description: \(error.localizedDescription)")
            XCTFail("Brazilian IBAN should be valid but got error: \(error)")
        }
    }

    func testBrazilianCountryData() async throws {
        do {
            let brazilModel = try await CountryModelsManager.shared.countryModel(for: "BR")
            print("Brazil country model:")
            print("- Country Code: \(brazilModel.CountryCode)")
            print("- Length: \(brazilModel.Length)")
            print("- Inner Structure: \(brazilModel.InnerStructure)")

            XCTAssertEqual(brazilModel.CountryCode, "BR")
            XCTAssertEqual(brazilModel.Length, 29, "Brazilian IBAN should be 29 characters")

            let testIBAN = "BR0200000000010670000117668C1"
            XCTAssertEqual(testIBAN.count, brazilModel.Length, "Test IBAN should match expected length")

        } catch {
            XCTFail("Failed to load Brazilian country model: \(error)")
        }
    }

    func testBrazilianIBANStructure() async throws {
        let brazilianIBAN = "BR0200000000010670000117668C1"
        let bban = String(brazilianIBAN.dropFirst(4))

        // Get Brazil's inner structure
        let brazilModel = try await CountryModelsManager.shared.countryModel(for: "BR")
        let innerStructure = brazilModel.InnerStructure

        print("Brazilian inner structure: \(innerStructure)")
        print("BBAN to validate: \(bban)")
        print("BBAN length: \(bban.count)")

        // Parse the inner structure: "F08F05F10U01A01"
        // F08 = 8 digits (bank code)
        // F05 = 5 digits (branch code)
        // F10 = 10 digits (account number)
        // U01 = 1 uppercase letter (account type)
        // A01 = 1 alphanumeric character (check digit)

        let expectedParts = [
            ("F08", 8, "00000000"),
            ("F05", 5, "01067"),
            ("F10", 10, "0000117668"),
            ("U01", 1, "C"),
            ("A01", 1, "1")
        ]

        var offset = 0
        for (i, (format, length, expectedValue)) in expectedParts.enumerated() {
            let endIndex = bban.index(bban.startIndex, offsetBy: offset + length)
            let part = String(bban[bban.index(bban.startIndex, offsetBy: offset)..<endIndex])

            print("Part \(i + 1) (\(format)): '\(part)' (expected: '\(expectedValue)', length: \(length))")

            // Test format compliance
            let formatResult = RFIBANHelper.isStringConformFormat(part, format: format)
            print("Format validation result for '\(part)' with format \(format): \(formatResult)")

            if !formatResult {
                print("❌ FAILED: Part '\(part)' does not conform to format \(format)")

                // Let's test with the modern format enum
                if let ibanFormat = IBANFormat(rawValue: String(format.first!)) {
                    let range = NSRange(location: 0, length: part.count)
                    let modernResult = ibanFormat.regex?.firstMatch(in: part, options: [], range: range) != nil
                    print("Modern format validation: \(modernResult)")
                    print("Format pattern: \(ibanFormat.pattern)")
                }
            } else {
                print("✅ PASSED: Part '\(part)' conforms to format \(format)")
            }

            XCTAssertTrue(formatResult, "Part '\(part)' should conform to format \(format)")

            offset += length
        }

        XCTAssertEqual(offset, bban.count, "All parts should account for entire BBAN")
    }

    func testBrazilianChecksumCalculation() {
        let brazilianIBAN = "BR0200000000010670000117668C1"

        // Test checksum calculation
        let calculatedChecksum = RFIBANHelper.checkSumForIban(brazilianIBAN)
        print("Calculated checksum: \(calculatedChecksum)")

        let expectedChecksum = Int(String(brazilianIBAN[brazilianIBAN.index(brazilianIBAN.startIndex, offsetBy: 2)..<brazilianIBAN.index(brazilianIBAN.startIndex, offsetBy: 4)]))!
        print("Expected checksum: \(expectedChecksum)")

        XCTAssertEqual(calculatedChecksum, expectedChecksum, "Calculated checksum should match IBAN checksum")
    }

    func testBrazilianCharacterConversion() {
        let brazilianIBAN = "BR0200000000010670000117668C1"

        // Test the character conversion step in checksum
        let bankCode = String(brazilianIBAN.dropFirst(4))
        let countryCode = String(brazilianIBAN.prefix(2))
        let rearranged = "\(bankCode)\(countryCode)00"

        print("Rearranged for checksum: \(rearranged)")

        let numericString = RFIBANHelper.intValueForString(rearranged.uppercased())
        print("Numeric conversion: \(numericString)")

        XCTAssertFalse(numericString.isEmpty, "Character conversion should not return empty string")

        // Test modern conversion
        let validator = IBANValidator()
        let modernNumeric = validator.convertToNumeric(rearranged.uppercased())
        print("Modern numeric conversion: \(modernNumeric)")

        XCTAssertEqual(numericString, modernNumeric, "Legacy and modern conversion should match")
    }

    func testOtherValidBrazilianIBANs() {
        let brazilianIBANs = [
            "BR0200000000010670000117668C1", // The failing one
            "BR9700360305000010009795493P1",  // From the country test data
            "BR1800000000141455123924100C2",  // Another test case
        ]

        for iban in brazilianIBANs {
            let result = RFIBANHelper.isValidIBAN(iban)
            print("Testing \(iban): \(result)")

            if result != .validIban {
                print("FAILED: \(iban) returned \(result)")

                // Debug the failure
                print("Length: \(iban.count)")
                let bban = String(iban.dropFirst(4))
                print("BBAN: \(bban), length: \(bban.count)")
            }

            XCTAssertEqual(result, .validIban, "Brazilian IBAN should be valid: \(iban)")
        }
    }
}