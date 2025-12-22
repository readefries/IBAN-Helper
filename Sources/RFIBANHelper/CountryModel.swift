//
//  CountryModel.swift
//  RFIBANHelper
//
//  Created by Hindrik Bruinsma on 08/12/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

public struct CountryModel: Codable, Sendable {
    public var CountryCode: String
    public var Length: Int
    public var InnerStructure: String
}
