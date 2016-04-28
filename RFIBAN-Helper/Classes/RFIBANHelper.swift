
import Foundation

public enum IbanCheckStatus: Int {
  case ValidIban
  case InvalidCountryCode
  case InvalidBankAccount
  case InvalidChecksum
  case InvalidInnerStructure
  case InvalidStartBytes
  case InvalidCharacters
  case InvalidLength
}

public class RFIBANHelper: NSObject {

  static let decimalsAndCharacters = "^([A-Za-z0-9])*$"
  static let decimalsAndUppercaseCharacters = "^([A-Z0-9])*$"
  static let decimalsAndLowercaseCharacters = "^([a-z0-9])*$"
  static let characters = "^([A-Za-z])*$"
  static let decimals = "^(0-9)*$"
  static let lowercaseCharacters = "^(a-z)*$"
  static let uppercaseCharacters = "^(A-Z)*$"

  static let startBytesRegex = "^([A-Z]{2}[0-9]{2})$"

  public static func createIBAN(account: String, bic: String) -> String {

    return String()
  }

  public static func isValidIBAN(iban: String) -> IbanCheckStatus {
    if iban.rangeOfString(RFIBANHelper.decimalsAndCharacters, options: .RegularExpressionSearch) == nil
    {
      return .InvalidCharacters
    }

    let countryCode = iban.substringWithRange(Range<String.Index>(iban.startIndex..<iban.startIndex.advancedBy(2)))

    let structure = RFIBANHelper.ibanStructure(countryCode)

    if structure.keys.count == 0
    {
      return .InvalidCountryCode
    }

    if iban.substringWithRange(Range<String.Index>(
    iban.startIndex..<iban.startIndex.advancedBy(4))).rangeOfString(
      RFIBANHelper.startBytesRegex,
      options: .RegularExpressionSearch) == nil
    {
      return.InvalidStartBytes
    }

    let nf = NSNumberFormatter()
    let innerStructure = structure["InnerStructure"] as! String

    var ofset = 4 // skip the country code and controll number

    for i in 0...(innerStructure.characters.count/3)-1
    {
      let startIndex = i * 3

      let format = innerStructure.substringWithRange(Range<String.Index>(innerStructure.startIndex.advancedBy(startIndex)..<innerStructure.startIndex.advancedBy(startIndex + 1)))

      let formatLength = Int(innerStructure.substringWithRange(Range<String.Index>(innerStructure.startIndex.advancedBy(startIndex + 1)..<innerStructure.startIndex.advancedBy(startIndex + 3))))

      if !RFIBANHelper.isStringConformFormat(iban.substringWithRange(Range<String.Index>(iban.startIndex.advancedBy(ofset)..<iban.startIndex.advancedBy(ofset + formatLength!))), format: format) {
        return .InvalidInnerStructure
      }

      ofset = 4 + (i * 3)
    }

    //  1. Check that the total IBAN length is correct as per the country. If not, the IBAN is invalid.
    if let expectedLength = structure["Length"] as? NSNumber
    {
      if expectedLength.integerValue != iban.characters.count
      {
        return .InvalidLength
      }
    }

    let expectedCheckSum = nf.numberFromString(iban.substringWithRange(Range<String.Index>(iban.startIndex.advancedBy(2)..<iban.startIndex.advancedBy(4))))!.integerValue
    if expectedCheckSum == RFIBANHelper.checkSumForIban(iban, structure:structure)
    {
      return .ValidIban
    }

    return .InvalidChecksum
  }

  public static func isStringConformFormat(string: String, format: String) -> Bool
  {
    if format == "A"
    {
      return string.rangeOfString(RFIBANHelper.decimalsAndCharacters, options: .RegularExpressionSearch) == nil
    } else if format == "B"
    {
      return string.rangeOfString(RFIBANHelper.decimalsAndUppercaseCharacters, options: .RegularExpressionSearch) == nil
    } else if format == "C"
    {
      return string.rangeOfString(RFIBANHelper.characters, options: .RegularExpressionSearch) == nil
    } else if format == "F"
    {
      return string.rangeOfString(RFIBANHelper.decimals, options: .RegularExpressionSearch) == nil
    } else if format == "L"
    {
      return string.rangeOfString(RFIBANHelper.lowercaseCharacters, options: .RegularExpressionSearch) == nil
    } else if format == "U"
    {
      return string.rangeOfString(RFIBANHelper.uppercaseCharacters, options: .RegularExpressionSearch) == nil
    } else if format == "W"
    {
      return string.rangeOfString(RFIBANHelper.decimalsAndLowercaseCharacters, options: .RegularExpressionSearch) == nil
    } else {
      return false
    }
  }

  public static func ibanStructure(countryCode: String) -> Dictionary<String, NSObject> {

    if let path = NSBundle(forClass: object_getClass(self)).pathForResource("IBANStructure", ofType: "plist") {
      let ibanStructureList = NSArray(contentsOfFile:path)

      for ibanStructure in ibanStructureList! {
        if ibanStructure["Country"] as! String == countryCode {
          return ibanStructure as! Dictionary<String, NSObject>
        }
      }
    }

    return Dictionary()
  }

  public static func checkSumForIban(iban: String, structure: Dictionary<String, NSObject>) -> Int {
    //  2. Replace the two check digits by 00 (e.g., GB00 for the UK).
    //  3. Move the four initial characters to the end of the string.
    var checkedIban = String(format: "%@%@00", iban.substringFromIndex(iban.startIndex.advancedBy(4)), iban.substringToIndex(iban.startIndex.advancedBy(2)))

    //  4. Replace the letters in the string with digits, expanding the string as necessary, such that A or
    //  a = 10, B or b = 11, and Z or z = 35. Each alphabetic character is therefore replaced by 2 digits.
    //  5. Convert the string to an integer (i.e., ignore leading zeroes).
    checkedIban = RFIBANHelper.intValueForString(checkedIban.uppercaseString)

    //  6. Calculate mod-97 of the new number, which results in the remainder.

    let remainder = ISO7064.MOD97_10(checkedIban)

    //  7.Subtract the remainder from 98, and use the result for the two check digits. If the result is a single digit number,
    //  pad it with a leading 0 to make a two-digit number.

    return 98 - remainder;
  }

 

  public static func intValueForString(string: String) -> String {
    if string.rangeOfString(RFIBANHelper.decimalsAndUppercaseCharacters, options: .RegularExpressionSearch) == nil
    {
      return ""
    }

    var returnValue = NSMutableString()

    for charValue in string.unicodeScalars {

      var decimalCharacter = 0

      // 0-9
      if charValue.value >= 48 && charValue.value <= 57 {
        decimalCharacter = Int(charValue.value) - 48
      } else if charValue.value >= 65 && charValue.value <= 90 {
        decimalCharacter = Int(charValue.value) - 55
      }

      returnValue.appendString(String(decimalCharacter))
    }

    return String(returnValue)
  }

  public static func preFixZerosToAccount(bankNumber: String, length: Int) -> String {

    var banknumberWithPrefixes = bankNumber

    for _ in bankNumber.characters.count...length {
      banknumberWithPrefixes = String(format:"0%@", bankNumber)
    }

    return banknumberWithPrefixes;
  }
}
