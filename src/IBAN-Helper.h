//
//  IBAN-Helper.h
//  IBAN Helper
//
//  Created by Hendrik Bruinsma on 24-09-12.
//  Copyright (c) 2012 XS4some. All rights reserved.
//
//  IBAN Helper is licensed under MIT License Permission is hereby granted, free of charge, to any
//  person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
//  to permit persons to whom the Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or
//  substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
//  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Dataset used from UN/CEFACT - TBG 5 Finance site : http://www.tbg5-finance.org/?ibandocs.shtml

#import <Foundation/Foundation.h>

// Don't use NSCharacterSet upperCaseCharacterSet or lowerCaseCharacterSet,
// as that would make non latin characters valid. Which or not valid in IBAN.

#define kLetterAndDecimals @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"
#define kLetters @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ"
#define kLettersLowerCase @"abcdefghijklmnopqrstuvwxyz"
#define kLettersUpperCase @"ABCDEFGHIJKLKMNOPQRSTUVWXYZ"
#define kDecimals @"0123456789"

#define kIbanStructureFile @"IBANStructure.plist"

#define CHAR_VALUE(a) (int)((unichar)(a) - (unichar)'A' + 10)

typedef enum {
    IbanCheckStatusOk = 0,
    IbanCheckStatusInvalidCountryCode, // Unknown country code
    IbanCheckStatusInvalidBankAccount, // e.g. Dutch bank account number with a lengt of 7 or more digits should be dividible by 11
    IbanCheckStatusInvalidCheckSum,
    IbanCheckStatusInvalidInnerStructure, // e.g. country specific part not correct
    IbanCheckStatusInvalidStartBytes, // e.g. country code and checksum no in correct format
    IbanCheckStatusInvalidCharacters,
    IbanCheckInvalidLength
} IbanCheckStatus;

@interface IBAN_Helper : NSObject

- (IbanCheckStatus) isValidIban:(NSString *)iban;
- (NSString *)ibanWithAccount:(NSString *)account andBic:(NSString *)bic;

@end
