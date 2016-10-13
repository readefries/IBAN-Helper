
import Foundation

public class ISO7064: NSObject {
  public static let MOD97_10_Valid_Chars = "^(0-9)*$"

  public static func MOD97_10(_ input: String) -> Int {

    if (input.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil){
      return NSNotFound
    }

    var remainingInput = input

    while(true) {
      let chunkSize = remainingInput.characters.count < 9 ? remainingInput.characters.count : 9

      let chunk = Int(remainingInput.substring(with: Range<String.Index>(remainingInput.startIndex..<remainingInput.index(remainingInput.startIndex, offsetBy: chunkSize))))

      if chunk! < 97 || remainingInput.characters.count < 3 {
        break
      }

      let remainder = chunk! % 97
      remainingInput = String(format: "%d%@", remainder, remainingInput.substring(from: remainingInput.index(remainingInput.startIndex, offsetBy: chunkSize)))
    }

    return Int(remainingInput)!
  }
}
