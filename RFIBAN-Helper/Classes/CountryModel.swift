//
//  CountryModel.swift
//  RFIBANHelper
//
//  Created by Hindrik Bruinsma on 08/12/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

// MARK: - Modern Error Handling

public enum IBANError: Error, LocalizedError {
    case invalidJSON
    case missingCountryData(String)
    case invalidFormat
    case checksumError
    case invalidStartBytes
    case invalidInnerStructure
    case invalidLength
    case invalidCountryCode
    case invalidBankAccount
    case invalidStructure
    case networkError(Error)
    case dataCorruption

    public var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return "Invalid JSON format in country data"
        case .missingCountryData(let code):
            return "Country data not found for code: \(code)"
        case .invalidFormat:
            return "Invalid IBAN format"
        case .checksumError:
            return "Invalid IBAN checksum"
        case .invalidStartBytes:
            return "Invalid IBAN start bytes"
        case .invalidInnerStructure:
            return "Invalid IBAN inner structure"
        case .invalidLength:
            return "Invalid IBAN length"
        case .invalidCountryCode:
            return "Invalid country code"
        case .invalidBankAccount:
            return "Invalid bank account number"
        case .invalidStructure:
            return "Invalid IBAN structure"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .dataCorruption:
            return "Country data corruption detected"
        }
    }
}

// MARK: - Country Model

public struct CountryModel: Codable, Hashable, Sendable {
    // MARK: - Legacy Properties (maintain exact naming for backward compatibility)
    public var CountryCode: String
    public var Length: Int
    public var InnerStructure: String

    // MARK: - New Optional Properties (won't break existing code)
    public let example: String?
    public let required: Bool
    public let sepa: Bool
    public let eu924_2009: Bool
    public let eur: Bool

    // MARK: - Modern Computed Properties (for new code)
    public var countryCode: String { CountryCode }
    public var length: Int { Length }
    public var innerStructure: String { InnerStructure }

    private enum CodingKeys: String, CodingKey {
        case CountryCode = "CountryCode"
        case Length = "Length"
        case InnerStructure = "InnerStructure"
        case example = "Example"
        case required = "Required"
        case sepa = "SEPA"
        case eu924_2009 = "EU924-2009"
        case eur = "EUR"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        CountryCode = try container.decode(String.self, forKey: .CountryCode)
        Length = try container.decode(Int.self, forKey: .Length)
        InnerStructure = try container.decode(String.self, forKey: .InnerStructure)

        // New properties with defaults for backward compatibility
        example = try container.decodeIfPresent(String.self, forKey: .example)
        required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? true
        sepa = try container.decodeIfPresent(Bool.self, forKey: .sepa) ?? false
        eu924_2009 = try container.decodeIfPresent(Bool.self, forKey: .eu924_2009) ?? false
        eur = try container.decodeIfPresent(Bool.self, forKey: .eur) ?? false
    }

    public init(CountryCode: String, Length: Int, InnerStructure: String, example: String? = nil, required: Bool = true, sepa: Bool = false, eu924_2009: Bool = false, eur: Bool = false) {
        self.CountryCode = CountryCode
        self.Length = Length
        self.InnerStructure = InnerStructure
        self.example = example
        self.required = required
        self.sepa = sepa
        self.eu924_2009 = eu924_2009
        self.eur = eur
    }
}
