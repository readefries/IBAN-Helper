//
//  CountryModels.swift
//  RFIBANHelper
//
//  Created by Hindrik Bruinsma on 08/12/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

public struct CountryModels: Sendable {
    private var models = [String: CountryModel]()
    
    public init() {
        loadModels()
    }
    
    public mutating func loadModels() {
        do {
            guard let jsonPath = Bundle.assets.path(forResource: "IBANStructure", ofType: "json")
                  else {
                preconditionFailure("Unable to read IBANStructure.json")
            }
            
            let jsonString = try String(contentsOfFile: jsonPath, encoding: .utf8)
            
            guard let jsonData = jsonString.data(using: .utf8)
                else {
                    preconditionFailure("Unable to read IBANStructure.json")
                }

            models = try JSONDecoder().decode([String: CountryModel].self, from: jsonData)
        } catch {
            preconditionFailure("Unable to parse JSON")
        }
    }
    
    public func model(_ countryCode: String) -> CountryModel? {
        return models[countryCode]
    }
}

extension Bundle {
    static let assets: Bundle = {
        let bundle: Bundle

        #if SWIFT_PACKAGE
        bundle = .module
        #else
        bundle = Bundle(for: object_getClass(CountryModels.self)!)
        #endif

        return bundle
    }()
}
