//
//  IBANValidator.swift
//  RFIBANHelper
//
//  Modern protocol-oriented IBAN validation
//

import Foundation
import os.log

// MARK: - Protocol Definitions

public protocol IBANValidating: Sendable {
    func validate(_ iban: String) async -> Result<Void, IBANError>
    func validateSync(_ iban: String) -> Result<Void, IBANError>
}

public protocol IBANCreating: Sendable {
    func createIBAN(accountNumber: String, bankCode: String?, countryCode: String) async -> Result<String, IBANError>
}

public protocol IBANFormatting: Sendable {
    func format(_ iban: String) -> String
    func removeFormatting(_ iban: String) -> String
}

// MARK: - Format Validation

public enum IBANFormat: String, CaseIterable {
    case alphanumeric = "A"          // A-Z, a-z, 0-9
    case alphanumericUppercase = "B" // A-Z, 0-9
    case alphabetic = "C"            // A-Z, a-z
    case numeric = "F"               // 0-9
    case lowercaseAlpha = "L"        // a-z
    case uppercaseAlpha = "U"        // A-Z
    case alphanumericLowercase = "W" // a-z, 0-9

    var pattern: String {
        switch self {
        case .alphanumeric:
            return "^[A-Za-z0-9]*$"
        case .alphanumericUppercase:
            return "^[A-Z0-9]*$"
        case .alphabetic:
            return "^[A-Za-z]*$"
        case .numeric:
            return "^[0-9]*$"
        case .lowercaseAlpha:
            return "^[a-z]*$"
        case .uppercaseAlpha:
            return "^[A-Z]*$"
        case .alphanumericLowercase:
            return "^[a-z0-9]*$"
        }
    }

    var regex: NSRegularExpression? {
        return try? NSRegularExpression(pattern: pattern, options: [])
    }
}

// MARK: - Modern IBAN Validator

public final class IBANValidator: IBANValidating, IBANCreating, IBANFormatting {
    private let countryProvider: CountryDataProviding
    private let logger = Logger(subsystem: "com.rfiban.helper", category: "IBANValidator")

    // Pre-compiled regex patterns for performance
    private static let ibanStructureRegex = try! NSRegularExpression(pattern: "^[A-Za-z0-9]{4,}$", options: [])
    private static let startBytesRegex = try! NSRegularExpression(pattern: "^[A-Z]{2}[0-9]{2}$", options: [])

    public init(countryProvider: CountryDataProviding = CountryModelsManager.shared) {
        self.countryProvider = countryProvider
    }

    // MARK: - Validation

    public func validate(_ iban: String) async -> Result<Void, IBANError> {
        let cleanIBAN = removeFormatting(iban)

        // Basic structure validation
        if let error = validateBasicStructure(cleanIBAN) {
            return .failure(error)
        }

        // Country-specific validation
        do {
            try await validateCountrySpecific(cleanIBAN)
            return .success(())
        } catch let error as IBANError {
            return .failure(error)
        } catch {
            return .failure(.invalidFormat)
        }
    }

    public func validateSync(_ iban: String) -> Result<Void, IBANError> {
        let cleanIBAN = removeFormatting(iban)

        // Basic structure validation only for sync
        if let error = validateBasicStructure(cleanIBAN) {
            return .failure(error)
        }

        // Basic checksum validation
        do {
            let checksumValid = try validateChecksum(cleanIBAN)
            return checksumValid ? .success(()) : .failure(.checksumError)
        } catch {
            return .failure(.checksumError)
        }
    }

    // MARK: - Creation

    public func createIBAN(accountNumber: String, bankCode: String? = nil, countryCode: String) async -> Result<String, IBANError> {
        guard !accountNumber.isEmpty else {
            return .failure(.invalidBankAccount)
        }

        do {
            let countryModel = try await countryProvider.countryModel(for: countryCode)

            let bankCodePart = bankCode ?? ""
            let accountPart = padAccount(accountNumber, targetLength: countryModel.length - 4 - bankCodePart.count)

            let ibanWithoutChecksum = "\(countryCode.uppercased())00\(bankCodePart)\(accountPart)"
            let checksum = try calculateChecksum(for: ibanWithoutChecksum)

            let finalIBAN = "\(countryCode.uppercased())\(String(format: "%02d", checksum))\(bankCodePart)\(accountPart)"

            // Validate the created IBAN
            let validationResult = await validate(finalIBAN)
            switch validationResult {
            case .success:
                return .success(finalIBAN)
            case .failure(let error):
                return .failure(error)
            }
        } catch let error as IBANError {
            return .failure(error)
        } catch {
            return .failure(.invalidFormat)
        }
    }

    // MARK: - Formatting

    public func format(_ iban: String) -> String {
        let clean = removeFormatting(iban)
        var result = ""

        for (index, char) in clean.enumerated() {
            if index > 0 && index % 4 == 0 {
                result += " "
            }
            result += String(char)
        }

        return result
    }

    public func removeFormatting(_ iban: String) -> String {
        return iban.replacingOccurrences(of: " ", with: "").uppercased()
    }

    // MARK: - Private Validation Methods

    private func validateBasicStructure(_ iban: String) -> IBANError? {
        // Length check
        guard iban.count >= 4 else {
            return .invalidStructure
        }

        // Character validation
        let range = NSRange(location: 0, length: iban.count)
        guard Self.ibanStructureRegex.firstMatch(in: iban, options: [], range: range) != nil else {
            return .invalidStructure
        }

        // Start bytes validation
        let startBytes = String(iban.prefix(4))
        let startRange = NSRange(location: 0, length: 4)
        guard Self.startBytesRegex.firstMatch(in: startBytes, options: [], range: startRange) != nil else {
            return .invalidStartBytes
        }

        return nil
    }

    private func validateCountrySpecific(_ iban: String) async throws {
        let countryCode = String(iban.prefix(2))
        let countryModel = try await countryProvider.countryModel(for: countryCode)

        // Length validation
        guard countryModel.length == iban.count else {
            throw IBANError.invalidLength
        }

        // BBAN validation
        let bban = String(iban.dropFirst(4))
        guard !bban.isEmpty else {
            throw IBANError.invalidBankAccount
        }

        // Inner structure validation
        try validateInnerStructure(bban, pattern: countryModel.innerStructure)

        // Checksum validation
        guard try validateChecksum(iban) else {
            throw IBANError.checksumError
        }
    }

    private func validateInnerStructure(_ bban: String, pattern: String) throws {
        var offset = 0
        let patternCount = pattern.count / 3

        for i in 0..<patternCount {
            let startIndex = i * 3
            let formatCode = String(pattern[pattern.index(pattern.startIndex, offsetBy: startIndex)])

            guard let lengthString = pattern[safe: startIndex + 1..<startIndex + 3],
                  let length = Int(lengthString) else {
                throw IBANError.invalidInnerStructure
            }

            guard let endOffset = bban.index(bban.startIndex, offsetBy: offset + length, limitedBy: bban.endIndex) else {
                throw IBANError.invalidInnerStructure
            }

            let part = String(bban[bban.index(bban.startIndex, offsetBy: offset)..<endOffset])

            guard let format = IBANFormat(rawValue: formatCode),
                  let regex = format.regex else {
                throw IBANError.invalidInnerStructure
            }

            let range = NSRange(location: 0, length: part.count)
            guard regex.firstMatch(in: part, options: [], range: range) != nil else {
                throw IBANError.invalidInnerStructure
            }

            offset += length
        }
    }

    private func validateChecksum(_ iban: String) throws -> Bool {
        let expectedChecksum = String(iban[iban.index(iban.startIndex, offsetBy: 2)..<iban.index(iban.startIndex, offsetBy: 4)])
        guard let expected = Int(expectedChecksum) else {
            throw IBANError.checksumError
        }

        let calculated = try calculateChecksum(for: iban)
        return expected == calculated
    }

    private func calculateChecksum(for iban: String) throws -> Int {
        let bankCode = String(iban.dropFirst(4))
        let countryCode = String(iban.prefix(2))
        let rearranged = "\(bankCode)\(countryCode)00"

        let numericString = convertToNumeric(rearranged.uppercased())
        let remainder = try ISO7064.mod97(numericString)

        return 98 - remainder
    }

    internal func convertToNumeric(_ string: String) -> String {
        var result = ""

        for char in string {
            if char.isNumber {
                result += String(char)
            } else if char.isLetter {
                let value = Int(char.asciiValue! - 55) // A=10, B=11, ..., Z=35
                result += String(value)
            }
        }

        return result
    }

    private func padAccount(_ account: String, targetLength: Int) -> String {
        guard account.count < targetLength else { return account }
        return String(repeating: "0", count: targetLength - account.count) + account
    }
}

// MARK: - Extensions

private extension String {
    subscript(safe range: Range<Int>) -> String? {
        guard range.lowerBound >= 0,
              range.upperBound <= count,
              range.lowerBound < range.upperBound else {
            return nil
        }

        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = index(self.startIndex, offsetBy: range.upperBound)

        return String(self[startIndex..<endIndex])
    }
}