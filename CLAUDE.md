# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RFIBAN-Helper is a Swift library for validating International Bank Account Numbers (IBANs). It supports both CocoaPods and Swift Package Manager distribution, with comprehensive validation based on country-specific IBAN rules from the UN/CEFACT dataset.

## Development Commands

### Testing
- **Run all tests**: `make test` or `xcodebuild test -project Example/RFIBANHelper.xcodeproj -scheme RFIBANHelper build test -destination platform='iOS Simulator,name=iPhone 16,OS=latest'`
- Tests are located in `Example/Tests/`

### CocoaPods Operations
- **Validate podspec**: `make validate` or `bundle exec pod lib lint --quick --allow-warnings`
- **Publish to CocoaPods**: `make publish` (requires trunk access)
- **Install dependencies**: `make install`

### Clean
- **Clean build artifacts**: `make clean`

### Data Import
- **Import IBAN country data**: `make import` (runs `import.php` to update country rules)

## Architecture

### Core Components

- **RFIBANHelper.swift**: Main validation class with static methods
  - `isValidIBAN(_:)`: Primary validation function returning `IbanCheckStatus`
  - `createIBAN(_:bic:countryCode:)`: IBAN generation from account details
  - Country-specific format validation using regex patterns

- **CountryModels.swift**: Manages country-specific IBAN rules
  - Loads configuration from `IBANStructure.json`
  - Provides country codes, lengths, and inner structure patterns

- **ISO7064.swift**: Implements MOD-97 checksum algorithm for IBAN validation

### Data Structure

- **IBANStructure.json**: Contains validation rules for all supported countries
  - Country codes, IBAN lengths, inner structure patterns
  - Format codes: A (alphanumeric), F (numeric), U (uppercase), etc.

### Distribution

- **Swift Package Manager**: Defined in `Package.swift`
  - Main target: `RFIBANHelper` (sources in `RFIBAN-Helper/Classes/`)
  - Test target: `RFIBANHelperTests` (sources in `Example/Tests/`)

- **CocoaPods**: Configured in `RFIBAN-Helper.podspec`
  - Supports iOS 9.0+, Swift 5.0
  - Resources include `IBANStructure.json`

### Testing Strategy

Tests validate:
- IBAN format validation for multiple countries
- Checksum calculation accuracy
- Error handling for invalid inputs
- Country-specific structure validation
- Edge cases (empty strings, invalid characters, wrong lengths)

## Development Notes

- The library uses country-specific validation rules loaded from JSON
- IBAN validation follows ISO 13616 standard with MOD-97 checksum
- All validation is performed statically without external dependencies
- Example project in `Example/` demonstrates usage patterns