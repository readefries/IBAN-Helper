
import XCTest

@testable import RFIBANHelper

// MARK: - Core IBAN Validation Tests

class IBANValidationTests: XCTestCase {
  private let validator = IBANValidator()

  override func setUp() async throws {
    try await super.setUp()
    // Ensure country data is loaded
    _ = try await CountryModelsManager.shared.allCountries()
  }

  // MARK: - Core IBAN Validation Tests

  func testValidIBANs() {
    let validIBANs = [
      "GB82WEST12345698765432",
      "NL20INGB0001234567",
      "HU42117730161111101800000000"
    ]

    for iban in validIBANs {
      let result = RFIBANHelper.isValidIBAN(iban)
      XCTAssertEqual(result, .validIban, "\(iban) should be a valid IBAN")
    }
  }

  func testInvalidIBANs() {
    let invalidTestCases: [(iban: String, expectedStatus: IbanCheckStatus)] = [
      ("", .invalidStructure),
      ("ES", .invalidStructure),
      ("NL26", .invalidBankAccount),
      ("NLKR", .invalidStartBytes),
      ("KR00BANK0123456789", .invalidCountryCode)
    ]

    for testCase in invalidTestCases {
      let result = RFIBANHelper.isValidIBAN(testCase.iban)
      XCTAssertEqual(result, testCase.expectedStatus, "IBAN \(testCase.iban) should return \(testCase.expectedStatus)")
    }
  }

  // MARK: - Async Modern API Tests

  func testAsyncValidation() async throws {
    let validIBAN = "GB82WEST12345698765432"
    let result = await validator.validate(validIBAN)

    switch result {
    case .success:
      XCTAssert(true, "Valid IBAN should pass async validation")
    case .failure(let error):
      XCTFail("Valid IBAN failed async validation with error: \(error)")
    }
  }

  func testAsyncInvalidValidation() async throws {
    let invalidIBAN = "INVALID"
    let result = await validator.validate(invalidIBAN)

    switch result {
    case .success:
      XCTFail("Invalid IBAN should not pass async validation")
    case .failure:
      XCTAssert(true, "Invalid IBAN correctly failed async validation")
    }
  }

  // MARK: - Backward Compatibility Tests

  func testLegacyAPICompatibility() {
    // Ensure legacy API still works exactly as before
    let legacyResult = RFIBANHelper.isValidIBAN("GB82WEST12345698765432")
    XCTAssertEqual(legacyResult, .validIban, "Legacy API should still work")

    let invalidLegacyResult = RFIBANHelper.isValidIBAN("INVALID")
    XCTAssertEqual(invalidLegacyResult, .invalidStructure, "Legacy API should handle invalid IBANs")
  }

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

  // MARK: - Checksum Algorithm Tests

  func testISO7064_Mod_97_10() {
    let sut = "182316110001234567232100"
    let result = ISO7064.MOD97_10(sut)
    XCTAssertEqual(result, 78, "MOD-97 calculation should return 78 for test input")
  }

  func testISO7064_Mod_97_10_WithInvalidCharacters() {
    let sut = "INVALID CHARACTERS"
    let result = ISO7064.MOD97_10(sut)
    XCTAssertEqual(result, NSNotFound, "Invalid characters should return NSNotFound")
  }

  func testModernISO7064() throws {
    let sut = "182316110001234567232100"
    let result = try ISO7064.mod97(sut)
    XCTAssertEqual(result, 78, "Modern MOD-97 should produce same result as legacy")

    // Test error handling
    XCTAssertThrowsError(try ISO7064.mod97("INVALID")) { error in
      XCTAssertTrue(error is ISO7064.ValidationError, "Should throw ValidationError for invalid input")
    }

    XCTAssertThrowsError(try ISO7064.mod97("")) { error in
      XCTAssertTrue(error is ISO7064.ValidationError, "Should throw ValidationError for empty input")
    }
  }

  // MARK: - Edge Cases

  func testThatIbanWithOneCharacterMissingWillNotCrash() {
    let sut = "NL20INGB000123456"
    let result = RFIBANHelper.isValidIBAN(sut)
    XCTAssertEqual(result, .invalidInnerStructure, "IBAN with missing character should be invalid structure")
  }
}
