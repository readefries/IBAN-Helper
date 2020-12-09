# RFIBAN-Helper

[![CI Status](http://img.shields.io/travis/readefries/IBAN-Helper.svg?style=flat)](https://travis-ci.org/readefries/IBAN-Helper)
[![Version](https://img.shields.io/cocoapods/v/RFIBAN-Helper.svg?style=flat)](http://cocoapods.org/pods/RFIBAN-Helper)
[![License](https://img.shields.io/cocoapods/l/RFIBAN-Helper.svg?style=flat)](http://cocoapods.org/pods/RFIBAN-Helper)
[![Platform](https://img.shields.io/cocoapods/p/RFIBAN-Helper.svg?style=flat)](http://cocoapods.org/pods/RFIBAN-Helper)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


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

RFIBAN-Helper is available through [CocoaPods](http://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage). 

### CocoaPods
To install it, simply add the following line to your Podfile:

For Swift 5 use
```ruby
pod 'RFIBAN-Helper', '~> 4.0'
```

For Swift 4 use
```ruby
pod 'RFIBAN-Helper', '~> 3.0'
```

For Swift 3 use
```ruby
pod 'RFIBAN-Helper', '~> 2.0'
```

For Swift 2.3 use
```
pod 'RFIBAN-Helper', '~> 1.0'
```

### Carthage

Add this line in your Cartfile:

```
github 'readefries/IBAN-Helper' ~> 4.0
```

This library is available on Carthage starting from version `3.0.3`.

## Author

Hindrik Bruinsma, hbruinsma@xs4some.nl

## License

RFIBAN-Helper is available under the MIT license. See the LICENSE file for more info.
