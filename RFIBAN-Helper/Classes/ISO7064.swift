//
//  ISO7064.swift
//  RFIBAN-Helper
//
//  Created by Hindrik Bruinsma on 25/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

public class ISO7064: NSObject {
  public static let MOD97_10_Valid_Chars = "^(0-9)*$"

  public static func MOD97_10(input: String) -> Int {

    if (input.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) != nil){
      return NSNotFound
    }

    var remainingInput = input

    while(true)
    {
      let chunkSize = remainingInput.characters.count < 9 ? remainingInput.characters.count : 9

      let chunk = Int(remainingInput.substringWithRange(Range<String.Index>(remainingInput.startIndex..<remainingInput.startIndex.advancedBy(chunkSize))))
      if chunk < 97 || remainingInput.characters.count < 3 {
        break
      }

      let remainder = chunk! % 97
      remainingInput = String(format: "%d%@", remainder, remainingInput.substringFromIndex(remainingInput.startIndex.advancedBy(chunkSize)))
    }

    return Int(remainingInput)!
  }
}
