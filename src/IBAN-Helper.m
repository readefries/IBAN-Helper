//
//  IBAN-Helper.m
//  IBAN Calculator
//
//  Created by Hendrik Bruinsma on 24-09-12.
//  Copyright (c) 2012 XS4some. All rights reserved.
//

#import "IBAN-Helper.h"

@implementation IBAN_Helper

- (NSString *)ibanWithAccount:(NSString *)account andBic:(NSString *)bic
{
    if ([account length] < 1)
    {
        return @"";
    }
    
    //ISO 9362:2009 states the SWIFT code should be either 8 or 11 characters.
    if ([bic length] != 8 &&
        [bic length] != 11)
    {
        return @"";
    }
    
    NSString *countryCode = [bic substringWithRange:NSMakeRange(4, 2)];
    NSString *bankCode = [bic substringWithRange:NSMakeRange(0, 4)];
    
    NSDictionary *structure = [self ibanStructureWithCountryCode:countryCode];
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    
    int requiredLength = [[structure objectForKey:@"Length"] intValue];
    account = [self preFixZerosToAccount:account forLength:requiredLength - 4];
    
    
    NSString *ibanWithoutChecksum = [NSString stringWithFormat:@"%@00%@%@", countryCode, bankCode, account];
    
    int checksum = [self checkSumForIban:ibanWithoutChecksum withStructure:structure];
    
    return [NSString stringWithFormat:@"%@%d%@%@", countryCode, checksum, bankCode, account];
}

int mod (int a, int b)
{
    if(b < 0) //you can check for b == 0 separately and do what you want
        return mod(-a, -b);
    int ret = a % b;
    if(ret < 0)
        ret+=b;
    return ret;
}

- (IbanCheckStatus) isValidIban:(NSString *)iban
{
    NSDictionary *structure = [self ibanStructureWithCountryCode:[iban substringWithRange:NSMakeRange(0, 2)]];
    
    // contains chars other than (a-zA-Z0-9)
    NSCharacterSet *invalidChars = [[NSCharacterSet characterSetWithCharactersInString:kLetterAndDecimals] invertedSet];
    
    if ([iban rangeOfCharacterFromSet:invalidChars].location != NSNotFound)
    {
        return IbanCheckStatusInvalidCharacters;
    }
    
    NSCharacterSet *letterSet = [[NSCharacterSet characterSetWithCharactersInString:kLetters] invertedSet];
    
    //Should start with two letters and then two digits
    if (([[iban substringWithRange:NSMakeRange(0, 2)] rangeOfCharacterFromSet:letterSet].location != NSNotFound) ||
        ([[iban substringWithRange:NSMakeRange(2, 2)] rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound))
    {
        return IbanCheckStatusInvalidStartBytes;
    }
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    
    NSString *innerStructure = [structure objectForKey:@"InnerStructure"];
    
    int ofset = 4;
    
    for (int i = 0;[innerStructure length] /3; i++)
    {
        int length = [nf numberFromString:[innerStructure substringWithRange:NSMakeRange(1 + i * 3, 2)]].intValue;
        
        if ([self isString:[iban substringWithRange:NSMakeRange(ofset, length)] conformFormat:[innerStructure substringWithRange:NSMakeRange(i * 3, 1)]])
            return IbanCheckStatusInvalidInnerStructure;
        
        ofset = 4 + (i * 3);
    }
    
    int expectedLength = [nf numberFromString:[structure objectForKey:@"Length"]].intValue;
    
    //  1. Check that the total IBAN length is correct as per the country. If not, the IBAN is invalid.
    if (expectedLength != iban.length)
    {
        return IbanCheckInvalidLength;
    }
    
    int expectedCheckSum = [nf numberFromString:[iban substringWithRange:NSMakeRange(2, 2)]].intValue;
    
    if (expectedCheckSum == [self checkSumForIban:iban withStructure:structure])
    {
        return IbanCheckStatusOk;
    }
 
    return IbanCheckStatusInvalidCheckSum;
}

- (int) checkSumForIban:(NSString *)iban withStructure:(NSDictionary *)structure
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];

    int expectedLength = [[structure objectForKey:@"Length"] intValue];
        
    //  2. Replace the two check digits by 00 (e.g., GB00 for the UK).
    //  3. Move the four initial characters to the end of the string.
    iban = [NSString stringWithFormat:@"%@%@00", [iban substringWithRange:NSMakeRange(4, expectedLength)], [iban substringWithRange:NSMakeRange(0, 2)]];
    
    //  4. Replace the letters in the string with digits, expanding the string as necessary, such that A or
    //  a = 10, B or b = 11, and Z or z = 35. Each alphabetic character is therefore replaced by 2 digits.
    
    NSString *innerStructure = [structure objectForKey:@"InnerStructure"];
    
    int bicLength = [nf numberFromString:[innerStructure substringWithRange:NSMakeRange(1, 2)]].intValue;
    int bic = [self intValueForString:[iban substringWithRange:NSMakeRange(4, bicLength)]];
    int country = [self intValueForString:[structure objectForKey:@"Country"]];
    
    iban = [NSString stringWithFormat:@"%d%@%d", bic, [iban substringWithRange:NSMakeRange(4, expectedLength - 6)], country];
    
    //  5. Convert the string to an integer (i.e., ignore leading zeroes).
    //  6. Calculate mod-97 of the new number, which results in the remainder.
    int remainder = [self remainderWithIbanString:iban];
    //  7.Subtract the remainder from 98, and use the result for the two check digits. If the result is a single digit number,
    //  pad it with a leading 0 to make a two-digit number.
    
    return 98 - remainder;
}

- (Boolean) isString:(NSString *)string conformFormat:(NSString *)format
{
    if ([format isEqualToString:@"A"])
    {
        //case "A": testpattern += "0-9A-Za-z"; break;
        NSCharacterSet *notLettersAndDecimalsSet = [[NSCharacterSet characterSetWithCharactersInString:kLetterAndDecimals] invertedSet];
        if ([string rangeOfCharacterFromSet:notLettersAndDecimalsSet].location != NSNotFound) {
            return NO;
        } else
        {
            return YES;
        }
    } else if ([format isEqualToString:@"B"])
    {
        //case "B": testpattern += "0-9A-Z"; break;
        NSString *decimalsAndUpperCaseletters = [NSString stringWithFormat:@"%@%@", kDecimals, kLettersUpperCase];
        NSCharacterSet *notDecimalsAndUpperCaseletters = [[NSCharacterSet characterSetWithCharactersInString:decimalsAndUpperCaseletters] invertedSet];
        if ([string rangeOfCharacterFromSet:notDecimalsAndUpperCaseletters].location != NSNotFound) {
            return NO;
        } else
        {
            return YES;
        }
    } else if ([format isEqualToString:@"C"])
    {
        //case "C": testpattern += "A-Za-z"; break;
        NSCharacterSet *notLetters = [[NSCharacterSet characterSetWithCharactersInString:kLetters] invertedSet];
        if ([string rangeOfCharacterFromSet:notLetters].location != NSNotFound) {
            return NO;
        } else
        {
            return YES;
        }
    } else if ([format isEqualToString:@"F"])
    {
        //case "F": testpattern += "0-9"; break;
        NSCharacterSet *notNumbers = [[NSCharacterSet characterSetWithCharactersInString:kDecimals] invertedSet];
        if ([string rangeOfCharacterFromSet:notNumbers].location != NSNotFound) {
            return NO;
        } else
        {
            return YES;
        }

    } else if ([format isEqualToString:@"L"])
    {
        //case "L": testpattern += "a-z"; break;
        NSCharacterSet *notLowerCaseLetters = [[NSCharacterSet characterSetWithCharactersInString:kLettersLowerCase] invertedSet];
        if ([string rangeOfCharacterFromSet:notLowerCaseLetters].location != NSNotFound) {
            return NO;
        } else
        {
            return YES;
        }
    } else if ([format isEqualToString:@"U"])
    {
        //case "U": testpattern += "A-Z"; break;
        NSCharacterSet *notUperCaseLetters = [[NSCharacterSet characterSetWithCharactersInString:kLettersUpperCase] invertedSet];
        if ([string rangeOfCharacterFromSet:notUperCaseLetters].location != NSNotFound) {
            return NO;
        } else
        {
            return YES;
        }

    } else if ([format isEqualToString:@"W"])
    {
        //case "W": testpattern += "0-9a-z"; break; }
        NSString *decimalsAndLowerCaseletters = [NSString stringWithFormat:@"%@%@", kDecimals, kLettersLowerCase];
        NSCharacterSet *notDecimalsAndLowerCaseLettes = [[NSCharacterSet characterSetWithCharactersInString:decimalsAndLowerCaseletters] invertedSet];
        if ([string rangeOfCharacterFromSet:notDecimalsAndLowerCaseLettes].location != NSNotFound) {
            return NO;
        } else
        {
            return YES;
        }
    } else
    {
        return NO;
    }
}

- (NSDictionary *)ibanStructureWithCountryCode:(NSString *)countryCode
{
    NSArray *ibanCountryList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kIbanStructureFile ofType:nil]];
    
    for (NSDictionary *ibanStructure in ibanCountryList)
    {
        if ([[ibanStructure objectForKey:@"Country"] isKindOfClass:[NSString class]]
             && [[ibanStructure objectForKey:@"Country"] isEqualToString:countryCode]) {
            return ibanStructure;
        }
    }
    
    return nil;
}

- (int) remainderWithIbanString:(NSString *)ibanString
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
//    Piece-wise calculation D mod 97 can be done in many ways. One such way is as follows:[14]
//    1. Starting from the leftmost digit of D, construct a number using the first 9 digits and call it N.[Note 3]
//    2. Calculate N mod 97.
//    3. Construct a new 9 digit N from the above result (2) followed by the next 7 digits of D. If there are fewer than 7 digits remaining in D but at least one, then construct a new N, which will have less than 9 digits, from the above result (2) followed by the remaining digits of D.
//    4. Repeat steps 2–3 until all the digits of D have been processed.
//    5. The result of the final calculation in (2) will be D mod 97 = N mod 97.
    
    int loops = (ibanString.length - (ibanString.length % 9)) / 9;
    int chunk = 0;
    int remainder = 0;
    
    for (int i = 0; i < loops; i++)
    {
        if (i == 0)
        {
            chunk = [nf numberFromString:[ibanString substringWithRange:NSMakeRange(0, 9)]].intValue;
        } else
        {
            chunk = [nf numberFromString:[NSString stringWithFormat:@"%d%@", remainder,[ibanString substringWithRange:NSMakeRange(i * 9, 7)]]].intValue;
        }
        
        remainder = mod(chunk, 97);
    }
    
    chunk = [nf numberFromString:[NSString stringWithFormat:@"%d%@", remainder,[ibanString substringWithRange:NSMakeRange(loops * 9, (ibanString.length % 9))]]].intValue;
    
    return mod(chunk, 97);
}

-(int) intValueForString:(NSString *)string
{
    NSCharacterSet *letterSet = [[NSCharacterSet characterSetWithCharactersInString:kLetters] invertedSet];
    //only accept a string
    if([string rangeOfCharacterFromSet:letterSet].location != NSNotFound)
    {
        return 0;
    }
    
    string = [string uppercaseString];
    
    unichar singleChar;
    NSString* returnValue = @"";
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    
    for (int i = 0; i < [string length]; i ++)
    {
        singleChar = [string characterAtIndex:i];
        returnValue =  [NSString stringWithFormat:@"%@%@",returnValue,[nf stringFromNumber:[NSNumber numberWithInt:CHAR_VALUE(singleChar)]]];
    }
    
    return [nf numberFromString:returnValue].intValue;
}

- (NSString *) preFixZerosToAccount:(NSString *)bankNumber forLength:(int)length
{
    for (int i = [bankNumber length]; i < length; i++)
    {
        bankNumber = [NSString stringWithFormat:@"0%@", bankNumber];
    }
    
    return bankNumber;
}

@end
