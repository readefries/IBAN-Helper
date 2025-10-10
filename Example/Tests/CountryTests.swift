//
//  CountryTests.swift
//  RFIBANHelper_Tests
//
//  Country-specific IBAN validation tests
//  Created by Alin Radut on 4/4/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest

@testable import RFIBANHelper

final class CountrySpecificIBANTests: XCTestCase {
    private let validator = IBANValidator()

    override func setUp() async throws {
        try await super.setUp()
        // Ensure country data is loaded
        _ = try await CountryModelsManager.shared.allCountries()
    }

    // MARK: - Parameterized Country Tests

    func testValidIBANsByCountry() {
        let validIBANs: [String: String] = [
            "AL": "AL06202111090000000005012075",
            "AD": "AD1000060004451247870930",
            "AZ": "AZ04UBAZ04003214540060AZN001",
            "BH": "BH02CITI00001077181611",
            "BE": "BE45096920886089",
            "BA": "BA391011606058553319",
            "BR": "BR9700360305000010009795493P1",
            "VG": "VG48NOSC0000000005002993",
            "BG": "BG02RZBB91551002755190",
            "CR": "CR79015202220005614288",
            "DK": "DK0220005036459478",
            "DE": "DE02100500000024290661",
            "DO": "DO22BCBH00000000011003290022",
            "EE": "EE021700017000459042",
            "FO": "FO1291810001441878",
            "FI": "FI0210403500314392",
            "FR": "FR7630006000011234567890189",
            "GE": "GE02TB7523045063700002",
            "GI": "GI04BARC020452163087000",
            "GR": "GR0201102160000021661309175",
            "GL": "GL2664710001504964",
            "GB": "GB11CITI18500811417983",
            "GT": "GT24CITI01010000000004146026",
            "IE": "IE02BOFI90008413113207",
            "IS": "IS040116381002305610911109",
            "IL": "IL020108380000002149431",
            "IT": "IT43K0310412701000000820420",
            "JO": "JO02SCBL1260000000018525836101",
            "KZ": "KZ04319C010005569698",
            "QA": "QA03QNBA000000000060565452001",
            "XK": "XK051301001002074155",
            "HR": "HR0223400093216312031",
            "KW": "KW02NBOK0000000000001000614589",
            "LV": "LV02HABA0551007820897",
            "LB": "LB02001400000302300023018319",
            "LI": "LI0308800000022875748",
            "LT": "LT027300010134441147",
            "LU": "LU020019175546294000",
            "MT": "MT02VALL22013000000040013752732",
            "MR": "MR1300012000010000009880016",
            "MU": "MU03MCBL0901000001879025000USD",
            "MK": "MK07200000625758632",
            "MD": "MD14MO2224ASV41884097100",
            "MC": "MC2412739000710075018000P14",
            "ME": "ME25505120000000466170",
            "NL": "NL02ABNA0457180536",
            "NO": "NO0239916835985",
            "AT": "AT021100000622888600",
            "PK": "PK02SCBL0000001925518401",
            "PS": "PS06ARAB000000009040781605610",
            "PL": "PL02103000190109780401676562",
            "PT": "PT50003600409911001102673",
            "RO": "RO02BRDE445SV75163474450",
            "LC": "LC55HEMM000100010012001200023015",
            "SM": "SM07U0854009803000030174419",
            "ST": "ST23000200000289355710148",
            "SA": "SA0220000002480647579940",
            "SE": "SE0230000000030301099952",
            "CH": "CH020020720710117540C",
            "RS": "RS35105008054113238018",
            "SC": "SC74NOVH00000021002035257028SCR",
            "SK": "SK0202000000003679748552",
            "SI": "SI56011006000005649",
            "ES": "ES1321000555370200853027",
            "TL": "TL380030000000025923744",
            "TR": "TR020001000201529153355002",
            "CZ": "CZ0201000000199216760237",
            "TN": "TN5901026067111999766058",
            "UA": "UA123052990004149497803982794",
            "HU": "HU02116000060000000064247067",
            "AE": "AE020090004001079346500",
            "CY": "CY02002001950000357009822416"
        ]

        for (countryCode, iban) in validIBANs {
            let result = RFIBANHelper.isValidIBAN(iban)
            XCTAssertEqual(result, .validIban, "IBAN for \(countryCode) should be valid: \(iban)")
        }
    }

    // MARK: - Async Country Validation Tests

    func testAsyncCountryValidation() async throws {
        let testCountries = ["GB", "NL", "DE", "FR", "ES", "IT"]

        for countryCode in testCountries {
            do {
                let countryModel = try await CountryModelsManager.shared.countryModel(for: countryCode)
                XCTAssertEqual(countryModel.CountryCode, countryCode, "Country model should have correct country code")
                XCTAssertGreaterThan(countryModel.Length, 0, "Country should have valid IBAN length")
                XCTAssertFalse(countryModel.InnerStructure.isEmpty, "Country should have inner structure definition")
            } catch {
                XCTFail("Failed to load country model for \(countryCode): \(error)")
            }
        }
    }

    // MARK: - Country Data Management Tests

    func testCountryDataLoading() async throws {
        let countries = try await CountryModelsManager.shared.allCountries()
        XCTAssertFalse(countries.isEmpty, "Should load country data")
        XCTAssertGreaterThan(countries.count, 50, "Should load substantial number of countries")

        // Test specific well-known countries
        let gbModel = try await CountryModelsManager.shared.countryModel(for: "GB")
        XCTAssertEqual(gbModel.CountryCode, "GB")
        XCTAssertEqual(gbModel.Length, 22)

        let nlModel = try await CountryModelsManager.shared.countryModel(for: "NL")
        XCTAssertEqual(nlModel.CountryCode, "NL")
        XCTAssertEqual(nlModel.Length, 18)
    }

    func testCountrySupport() async {
        let supportedCountries = ["GB", "NL", "DE", "FR", "ES", "IT", "AT", "BE"]
        let unsupportedCountries = ["XX", "ZZ", "AA", "YY"]

        for country in supportedCountries {
            let isSupported = await CountryModelsManager.shared.isCountrySupported(country)
            XCTAssertTrue(isSupported, "\(country) should be supported")
        }

        for country in unsupportedCountries {
            let isSupported = await CountryModelsManager.shared.isCountrySupported(country)
            XCTAssertFalse(isSupported, "\(country) should not be supported")
        }
    }

    // MARK: - European Countries Focus Tests

    func testEuropeanUnionIBANs() {
        let euIBANs = [
            "AT021100000622888600",
            "BE45096920886089",
            "CY02002001950000357009822416",
            "CZ0201000000199216760237",
            "DE02100500000024290661",
            "DK0220005036459478",
            "EE021700017000459042",
            "ES1321000555370200853027",
            "FI0210403500314392",
            "FR7630006000011234567890189",
            "GR0201102160000021661309175",
            "HR0223400093216312031",
            "HU02116000060000000064247067",
            "IE02BOFI90008413113207",
            "IT43K0310412701000000820420",
            "LT027300010134441147",
            "LU020019175546294000",
            "LV02HABA0551007820897",
            "MT02VALL22013000000040013752732",
            "NL02ABNA0457180536",
            "PL02103000190109780401676562",
            "PT50003600409911001102673",
            "RO02BRDE445SV75163474450",
            "SE0230000000030301099952",
            "SI56011006000005649",
            "SK0202000000003679748552"
        ]

        for iban in euIBANs {
            let result = RFIBANHelper.isValidIBAN(iban)
            XCTAssertEqual(result, .validIban, "EU IBAN should be valid: \(iban)")
        }
    }

    // MARK: - Performance Tests

    func testCountryValidationPerformance() {
        let ibans = [
            "GB11CITI18500811417983",
            "NL02ABNA0457180536",
            "DE02100500000024290661",
            "FR7630006000011234567890189",
            "ES1321000555370200853027"
        ]

        measure {
            for _ in 0..<200 {
                for iban in ibans {
                    _ = RFIBANHelper.isValidIBAN(iban)
                }
            }
        }
    }

    // MARK: - Specific Issue Tests

    func testProblematicBrazilianIBAN() {
        // This IBAN was reported as failing validation but should be valid
        let problematicIBAN = "BR0200000000010670000117668C1"

        let result = RFIBANHelper.isValidIBAN(problematicIBAN)
        XCTAssertEqual(result, .validIban, "Brazilian IBAN \(problematicIBAN) should be valid")

        // Test length
        XCTAssertEqual(problematicIBAN.count, 29, "Brazilian IBAN should be 29 characters")

        // Test structure
        let countryCode = String(problematicIBAN.prefix(2))
        XCTAssertEqual(countryCode, "BR", "Should be Brazilian IBAN")

        let bban = String(problematicIBAN.dropFirst(4))
        XCTAssertEqual(bban.count, 25, "Brazilian BBAN should be 25 characters")
    }

    func testAsyncProblematicBrazilianIBAN() async {
        let problematicIBAN = "BR0200000000010670000117668C1"

        let result = await validator.validate(problematicIBAN)

        switch result {
        case .success:
            XCTAssert(true, "Brazilian IBAN should pass async validation")
        case .failure(let error):
            XCTFail("Brazilian IBAN failed async validation with error: \(error)")
        }
    }

    func testMultipleBrazilianIBANs() {
        let brazilianIBANs = [
            "BR9700360305000010009795493P1",  // Known working
            "BR0200000000010670000117668C1",  // Reported as failing
        ]

        for iban in brazilianIBANs {
            let result = RFIBANHelper.isValidIBAN(iban)
            XCTAssertEqual(result, .validIban, "Brazilian IBAN should be valid: \(iban)")
        }
    }
}
