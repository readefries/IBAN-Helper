# RFIBAN-Helper

[![CI Status](http://img.shields.io/travis/readefries/IBAN-Helper.svg?style=flat)](https://travis-ci.org/readefries/IBAN-Helper)
[![Version](https://img.shields.io/cocoapods/v/RFIBAN-Helper.svg?style=flat)](http://cocoapods.org/pods/RFIBAN-Helper)
[![License](https://img.shields.io/cocoapods/l/RFIBAN-Helper.svg?style=flat)](http://cocoapods.org/pods/RFIBAN-Helper)
[![Platform](https://img.shields.io/cocoapods/p/RFIBAN-Helper.svg?style=flat)](http://cocoapods.org/pods/RFIBAN-Helper)


A Swift helper class to validate IBAN accounts.
Feel happy to contribute!

The dataset used to validate the accounts, is from the [UN/CEFACT - TBG Finance site](http://www.tbg5-finance.org/).

## Usage

```Swift
  let IBAN = "GB82WEST12345698765432" //remove spaces -> the specs state IBAN should never be stored with spaces

  let result = RFIBANHelper.isValidIBAN(IBAN)

```



## Requirements

## Installation

RFIBAN-Helper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RFIBAN-Helper', '~> 2.0.1'
```

For Swift 2.3 use
```
pod 'RFIBAN-Helper', '~> 1.0.3'
```

## Author

Hindrik Bruinsma, de@readefries.nl

## License

RFIBAN-Helper is available under the MIT license. See the LICENSE file for more info.
