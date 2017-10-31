//: Playground - noun: a place where people can play

import UIKit
@testable import RFIBANHelper

let sut = "GR160110125000000001230065"

var result = RFIBANHelper.isValidIBAN(sut)

let no1 = "NO9370580671290"

result = RFIBANHelper.isValidIBAN(no1)

let no2 = "NO9350050669316"

result = RFIBANHelper.isValidIBAN(no2)

let no3 = "NO9386011117947"

result = RFIBANHelper.isValidIBAN(no3)


let iban = RFIBANHelper.createIBAN("70580671290", countryCode: "NO")