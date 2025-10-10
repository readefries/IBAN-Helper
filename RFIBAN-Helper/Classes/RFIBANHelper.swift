
import Foundation
import os.log

// MARK: - Legacy Status Enum

public enum IbanCheckStatus: Int, CaseIterable {
    case validIban
    case invalidCountryCode
    case invalidBankAccount
    case invalidChecksum
    case invalidInnerStructure
    case invalidStartBytes
    @available(*, deprecated, message: "Please use `invalidStructure` instead")
    case invalidCharacters
    case invalidLength
    case invalidStructure

    init(from error: IBANError) {
        switch error {
        case .invalidCountryCode, .missingCountryData:
            self = .invalidCountryCode
        case .invalidBankAccount:
            self = .invalidBankAccount
        case .checksumError:
            self = .invalidChecksum
        case .invalidInnerStructure:
            self = .invalidInnerStructure
        case .invalidStartBytes:
            self = .invalidStartBytes
        case .invalidLength:
            self = .invalidLength
        case .invalidStructure, .invalidFormat:
            self = .invalidStructure
        default:
            self = .invalidStructure
        }
    }
}

// MARK: - Modern RFIBANHelper

public final class RFIBANHelper {
    private static let validator = IBANValidator()
    private static let logger = Logger(subsystem: "com.rfiban.helper", category: "RFIBANHelper")

    // Legacy patterns - kept for backward compatibility
    @available(*, deprecated, message: "Use IBANValidator instead")
    static let ibanStructure = "^([A-Za-z0-9]{4,})*$"
    @available(*, deprecated, message: "Use IBANFormat enum instead")
    static let decimalsAndCharacters = "^([A-Za-z0-9])*$"
    @available(*, deprecated, message: "Use IBANFormat enum instead")
    static let decimalsAndUppercaseCharacters = "^([A-Z0-9])*$"
    @available(*, deprecated, message: "Use IBANFormat enum instead")
    static let decimalsAndLowercaseCharacters = "^([a-z0-9])*$"
    @available(*, deprecated, message: "Use IBANFormat enum instead")
    static let characters = "^([A-Za-z])*$"
    @available(*, deprecated, message: "Use IBANFormat enum instead")
    static let decimals = "^([0-9])*$"
    @available(*, deprecated, message: "Use IBANFormat enum instead")
    static let lowercaseCharacters = "^([a-z])*$"
    @available(*, deprecated, message: "Use IBANFormat enum instead")
    static let uppercaseCharacters = "^([A-Z])*$"
    @available(*, deprecated, message: "Use IBANValidator instead")
    static let startBytesRegex = "^([A-Z]{2}[0-9]{2})$"
    @available(*, deprecated, message: "Use CountryModelsManager.shared instead")
    static let countryModels = CountryModels()

    private init() {} // Prevent instantiation

    // MARK: - Modern API

    /// Validates an IBAN asynchronously with modern error handling
    /// - Parameter iban: The IBAN string to validate
    /// - Returns: Result containing success or detailed error
    public static func validateIBAN(_ iban: String) async -> Result<Void, IBANError> {
        logger.info("Validating IBAN: \(iban.prefix(4))****")
        return await validator.validate(iban)
    }

    /// Validates an IBAN synchronously (limited validation)
    /// - Parameter iban: The IBAN string to validate
    /// - Returns: Result containing success or detailed error
    public static func validateIBANSync(_ iban: String) -> Result<Void, IBANError> {
        return validator.validateSync(iban)
    }

    /// Creates an IBAN with modern async API
    /// - Parameters:
    ///   - accountNumber: Bank account number
    ///   - bankCode: Optional bank code
    ///   - countryCode: Two-letter country code
    /// - Returns: Result containing created IBAN or error
    public static func createIBAN(accountNumber: String, bankCode: String? = nil, countryCode: String) async -> Result<String, IBANError> {
        logger.info("Creating IBAN for country: \(countryCode)")
        return await validator.createIBAN(accountNumber: accountNumber, bankCode: bankCode, countryCode: countryCode)
    }

    /// Formats an IBAN with spaces for readability
    /// - Parameter iban: The IBAN to format
    /// - Returns: Formatted IBAN string
    public static func formatIBAN(_ iban: String) -> String {
        return validator.format(iban)
    }

    /// Removes formatting from an IBAN
    /// - Parameter iban: The formatted IBAN
    /// - Returns: Clean IBAN string
    public static func cleanIBAN(_ iban: String) -> String {
        return validator.removeFormatting(iban)
    }

    // MARK: - Legacy API (Deprecated but maintained for backward compatibility)

    @available(*, deprecated, message: "Use validateIBAN(_:) async -> Result instead")
  public static func createIBAN(_ account: String, bic: String? = nil, countryCode: String? = nil) -> String {
    countryModels.loadModels()

    if account.count < 1
    {
      return ""
    }

    if let bic = bic {
      //ISO 9362:2009 states the SWIFT code should be either 8 or 11 characters.
      if bic.count != 8 && bic.count != 11
      {
        return ""
      }

      let countryCode = bic[bic.index(bic.startIndex, offsetBy: 4)..<bic.index(bic.startIndex, offsetBy: 6)]
      let bankCode = bic[..<bic.index(bic.startIndex, offsetBy: 4)]
        
      guard let countryModel = countryModels.model(String(countryCode)) else {
        preconditionFailure("CountryModel not found for \(countryCode)")
      }
        
      let accountNumber = RFIBANHelper.preFixZerosToAccount(account, length: countryModel.Length - 4)

      let ibanWithoutChecksum = "\(countryCode)00\(bankCode)\(accountNumber)"

      let checksum = RFIBANHelper.checkSumForIban(ibanWithoutChecksum)

      return "\(countryCode)\(checksum)\(bankCode)\(accountNumber)"
    }

    if let countryCode = countryCode {
      let ibanWithoutChecksum = "\(countryCode)00\(account)"

      let checksum = RFIBANHelper.checkSumForIban(ibanWithoutChecksum)

      return "\(countryCode)\(checksum)\(account)"
    }

    return ""
  }

    @available(*, deprecated, message: "Use validateIBAN(_:) async -> Result instead")
  public static func isValidIBAN(_ iban: String) -> IbanCheckStatus {
        // Use modern validator but return legacy status
        let result = validator.validateSync(iban)

        switch result {
        case .success:
            return .validIban
        case .failure(let error):
            return IbanCheckStatus(from: error)
        }
  }

    @available(*, deprecated, message: "Use IBANFormat enum instead")
  public static func isStringConformFormat(_ string: String, format: String) -> Bool
  {
    guard !string.isEmpty, !format.isEmpty,
          let formatCode = format.first,
          let ibanFormat = IBANFormat(rawValue: String(formatCode)) else {
        return false
    }

    let formatLength = Int(String(format[format.index(format.startIndex, offsetBy: 1)...format.index(format.startIndex, offsetBy: 2)]))

    if formatLength != string.count {
      return false
    }

    guard let regex = ibanFormat.regex else {
        return false
    }

    let range = NSRange(location: 0, length: string.count)
    return regex.firstMatch(in: string, options: [], range: range) != nil
  }

    @available(*, deprecated, message: "Use IBANValidator.calculateChecksum instead")
  public static func checkSumForIban(_ iban: String) -> Int {
    //  2. Replace the two check digits by 00 (e.g., GB00 for the UK).
    //  3. Move the four initial characters to the end of the string.
    let bankCode = iban[iban.index(iban.startIndex, offsetBy: 4)...]
    let countryCode = iban[..<iban.index(iban.startIndex, offsetBy: 2)]
    var checkedIban = "\(bankCode)\(countryCode)00"

    //  4. Replace the letters in the string with digits, expanding the string as necessary, such that A or
    //  a = 10, B or b = 11, and Z or z = 35. Each alphabetic character is therefore replaced by 2 digits.
    //  5. Convert the string to an integer (i.e., ignore leading zeroes).
    checkedIban = RFIBANHelper.intValueForString(checkedIban.uppercased())

    //  6. Calculate mod-97 of the new number, which results in the remainder.

    let remainder = ISO7064.MOD97_10(checkedIban)

    //  7.Subtract the remainder from 98, and use the result for the two check digits. If the result is a single digit number,
    //  pad it with a leading 0 to make a two-digit number.

    return 98 - remainder;
  }

    @available(*, deprecated, message: "Use IBANValidator.convertToNumeric instead")
  public static func intValueForString(_ string: String) -> String {
    if string.range(of: RFIBANHelper.decimalsAndUppercaseCharacters, options: .regularExpression) == nil
    {
      return ""
    }

    let returnValue = NSMutableString()

    for charValue in string.unicodeScalars {

      var decimalCharacter = 0

      // 0-9
      if charValue.value >= 48 && charValue.value <= 57 {
        decimalCharacter = Int(charValue.value) - 48
      } else if charValue.value >= 65 && charValue.value <= 90 {
        decimalCharacter = Int(charValue.value) - 55
      }

      returnValue.append(String(decimalCharacter))
    }

    return returnValue as String
  }

    @available(*, deprecated, message: "Use IBANValidator.padAccount instead")
  public static func preFixZerosToAccount(_ bankNumber: String, length: Int) -> String {

    var banknumberWithPrefixes = bankNumber

    for _ in bankNumber.count...length {
      banknumberWithPrefixes = String(format:"0%@", bankNumber)
    }

    return banknumberWithPrefixes;
  }
}
