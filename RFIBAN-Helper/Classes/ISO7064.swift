
import Foundation

public class ISO7064: NSObject {
  public static let MOD97_10_Valid_Chars = "^(0-9)*$"

  public static func MOD97_10(_ input: String) -> Int {

    if (input.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil){
      return NSNotFound
    }

    var remainingInput = input

    while(true) {
      let chunkSize = remainingInput.count < 9 ? remainingInput.count : 9

      let chunk = Int(remainingInput[remainingInput.startIndex..<remainingInput.index(remainingInput.startIndex, offsetBy: chunkSize)])

      if chunk! < 97 || remainingInput.count < 3 {
        break
      }

      let remainder = chunk! % 97

      let nextChunk = remainingInput[remainingInput.index(remainingInput.startIndex, offsetBy: chunkSize)...]

      remainingInput = "\(remainder)\(nextChunk)"
    }

    return Int(remainingInput)!
  }
}
