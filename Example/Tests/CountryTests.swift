//
//  CountryTests.swift
//  RFIBANHelper_Tests
//
//  Created by Alin Radut on 4/4/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest

@testable import RFIBANHelper

class CountryTests: XCTestCase {
    func testValidityOfALIban() {
        let sut = "AL06202111090000000005012075"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfADIban() {
        let sut = "AD1000060004451247870930"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfAZIban() {
        let sut = "AZ04UBAZ04003214540060AZN001"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfBHIban() {
        let sut = "BH02CITI00001077181611"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfBEIban() {
        let sut = "BE45096920886089"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfBAIban() {
        let sut = "BA391011606058553319"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfBRIban() {
        let sut = "BR0200000000010670000117668C1"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfVGIban() {
        let sut = "VG48NOSC0000000005002993"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfBGIban() {
        let sut = "BG02RZBB91551002755190"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfCRIban() {
        let sut = "CR79015202220005614288"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfDKIban() {
        let sut = "DK0220005036459478"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfDEIban() {
        let sut = "DE02100500000024290661"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfDOIban() {
        let sut = "DO22BCBH00000000011003290022"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

//    func testValidityOfSVIban() {
//        let sut = "SV43ACAT00000000000000123123"
//
//        let result = RFIBANHelper.isValidIBAN(sut)
//
//        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
//    }

    func testValidityOfEEIban() {
        let sut = "EE021700017000459042"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfFOIban() {
        let sut = "FO1291810001441878"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfFIIban() {
        let sut = "FI0210403500314392"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfFRIban() {
        let sut = "FR7630006000011234567890189"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfGEIban() {
        let sut = "GE02TB7523045063700002"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfGIIban() {
        let sut = "GI04BARC020452163087000"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfGRIban() {
        let sut = "GR0201102160000021661309175"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfGLIban() {
        let sut = "GL2664710001504964"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfGBIban() {
        let sut = "GB11CITI18500811417983"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfGTIban() {
        let sut = "GT24CITI01010000000004146026"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

//    func testValidityOfIQIban() {
//        let sut = "IQ20CBIQ861800101010500"
//
//        let result = RFIBANHelper.isValidIBAN(sut)
//
//        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
//    }

    func testValidityOfIEIban() {
        let sut = "IE02BOFI90008413113207"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfISIban() {
        let sut = "IS040116381002305610911109"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfILIban() {
        let sut = "IL020108380000002149431"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfITIban() {
        let sut = "IT43K0310412701000000820420"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfJOIban() {
        let sut = "JO02SCBL1260000000018525836101"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfKZIban() {
        let sut = "KZ04319C010005569698"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfQAIban() {
        let sut = "QA03QNBA000000000060565452001"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfXKIban() {
        let sut = "XK051301001002074155"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfHRIban() {
        let sut = "HR0223400093216312031"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfKWIban() {
        let sut = "KW02NBOK0000000000001000614589"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfLVIban() {
        let sut = "LV02HABA0551007820897"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfLBIban() {
        let sut = "LB02001400000302300023018319"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfLIIban() {
        let sut = "LI0308800000022875748"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfLTIban() {
        let sut = "LT027300010134441147"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfLUIban() {
        let sut = "LU020019175546294000"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfMTIban() {
        let sut = "MT02VALL22013000000040013752732"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfMRIban() {
        let sut = "MR1300012000010000009880016"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfMUIban() {
        let sut = "MU03MCBL0901000001879025000USD"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfMKIban() {
        let sut = "MK07200000625758632"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfMDIban() {
        let sut = "MD14MO2224ASV41884097100"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfMCIban() {
        let sut = "MC2412739000710075018000P14"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfMEIban() {
        let sut = "ME25505120000000466170"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfNLIban() {
        let sut = "NL02ABNA0457180536"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfNOIban() {
        let sut = "NO0239916835985"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfATIban() {
        let sut = "AT021100000622888600"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfPKIban() {
        let sut = "PK02SCBL0000001925518401"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfPSIban() {
        let sut = "PS06ARAB000000009040781605610"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfPLIban() {
        let sut = "PL02103000190109780401676562"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfPTIban() {
        let sut = "PT50003600409911001102673"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfROIban() {
        let sut = "RO02BRDE445SV75163474450"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfLCIban() {
        let sut = "LC55HEMM000100010012001200023015"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfSMIban() {
        let sut = "SM07U0854009803000030174419"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfSTIban() {
        let sut = "ST23000200000289355710148"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfSAIban() {
        let sut = "SA0220000002480647579940"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfSEIban() {
        let sut = "SE0230000000030301099952"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfCHIban() {
        let sut = "CH020020720710117540C"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfRSIban() {
        let sut = "RS35105008054113238018"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfSCIban() {
        let sut = "SC74NOVH00000021002035257028SCR"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfSKIban() {
        let sut = "SK0202000000003679748552"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfSIIban() {
        let sut = "SI56011006000005649"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfESIban() {
        let sut = "ES1321000555370200853027"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfTLIban() {
        let sut = "TL380030000000025923744"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfTRIban() {
        let sut = "TR020001000201529153355002"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfCZIban() {
        let sut = "CZ0201000000199216760237"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfTNIban() {
        let sut = "TN5901026067111999766058"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfUAIban() {
        let sut = "UA123052990004149497803982794"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfHUIban() {
        let sut = "HU02116000060000000064247067"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

    func testValidityOfAEIban() {
        let sut = "AE020090004001079346500"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }

//    func testValidityOfBYIban() {
//        let sut = "BY86AKBB10100000002966000000"
//
//        let result = RFIBANHelper.isValidIBAN(sut)
//
//        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
//    }

    func testValidityOfCYIban() {
        let sut = "CY02002001950000357009822416"

        let result = RFIBANHelper.isValidIBAN(sut)

        XCTAssert(result == .validIban, "\(sut) should be a valid IBAN, yet the result is \(result)")
    }


}
