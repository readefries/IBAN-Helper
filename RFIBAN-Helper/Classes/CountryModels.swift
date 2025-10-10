//
//  CountryModels.swift
//  RFIBANHelper
//
//  Created by Hindrik Bruinsma on 08/12/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import os.log

// MARK: - Protocol Definitions

public protocol CountryDataProviding: Sendable {
    func countryModel(for code: String) async throws -> CountryModel
    func allCountries() async throws -> [CountryModel]
    func isCountrySupported(_ code: String) async -> Bool
}

// MARK: - Modern Country Models Manager

@MainActor
public final class CountryModelsManager: CountryDataProviding {
    public static let shared = CountryModelsManager()

    private var models: [String: CountryModel] = [:]
    private var isLoaded = false
    private let logger = Logger(subsystem: "com.rfiban.helper", category: "CountryModels")

    private init() {}

    // MARK: - Public API

    public func countryModel(for code: String) async throws -> CountryModel {
        try await ensureModelsLoaded()

        guard let model = models[code.uppercased()] else {
            throw IBANError.missingCountryData(code)
        }

        return model
    }

    public func allCountries() async throws -> [CountryModel] {
        try await ensureModelsLoaded()
        return Array(models.values).sorted { $0.countryCode < $1.countryCode }
    }

    public func isCountrySupported(_ code: String) async -> Bool {
        do {
            _ = try await countryModel(for: code)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Data Loading

    private func ensureModelsLoaded() async throws {
        guard !isLoaded else { return }

        logger.info("Loading country models from JSON")

        do {
            let data = try await loadCountryData()
            let decoder = JSONDecoder()

            models = try decoder.decode([String: CountryModel].self, from: data)
            isLoaded = true

            logger.info("Successfully loaded \(models.count) country models")
        } catch {
            logger.error("Failed to load country models: \(error.localizedDescription)")
            throw IBANError.invalidJSON
        }
    }

    private func loadCountryData() async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    guard let jsonPath = Bundle.assets.path(forResource: "IBANStructure", ofType: "json") else {
                        continuation.resume(throwing: IBANError.missingCountryData("IBANStructure.json"))
                        return
                    }

                    let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
                    continuation.resume(returning: data)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Cache Management

    public func reloadModels() async throws {
        isLoaded = false
        models.removeAll()
        try await ensureModelsLoaded()
    }

    public func clearCache() {
        isLoaded = false
        models.removeAll()
    }
}

// MARK: - Legacy Support

public class CountryModels {
    private let manager = CountryModelsManager.shared
    private var loadTask: Task<Void, Error>?

    public init() {}

    @available(*, deprecated, message: "Use CountryModelsManager.shared instead")
    public func loadModels() {
        loadTask = Task {
            try await manager.ensureModelsLoaded()
        }
    }

    @available(*, deprecated, message: "Use async countryModel(for:) instead")
    public func model(_ countryCode: String) -> CountryModel? {
        guard let loadTask = loadTask else {
            return nil
        }

        do {
            let semaphore = DispatchSemaphore(value: 0)
            var result: CountryModel?

            Task {
                try await loadTask.value
                do {
                    result = try await manager.countryModel(for: countryCode)
                } catch {
                    result = nil
                }
                semaphore.signal()
            }

            semaphore.wait()
            return result
        } catch {
            return nil
        }
    }
}

// MARK: - Bundle Extension

extension Bundle {
    static let assets: Bundle = {
        let bundle: Bundle

        #if SWIFT_PACKAGE
        bundle = .module
        #else
        bundle = Bundle(for: CountryModels.self)
        #endif

        return bundle
    }()
}
