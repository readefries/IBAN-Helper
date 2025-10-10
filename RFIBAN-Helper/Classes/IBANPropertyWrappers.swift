//
//  IBANPropertyWrappers.swift
//  RFIBANHelper
//
//  Modern property wrappers for IBAN handling
//

import Foundation
import SwiftUI

// MARK: - Property Wrappers

/// Property wrapper that validates IBAN values automatically
@propertyWrapper
public struct ValidatedIBAN {
    private var storage: String = ""
    private let validator = IBANValidator()

    public var wrappedValue: String {
        get { storage }
        set {
            Task {
                let result = await validator.validate(newValue)
                if case .success = result {
                    await MainActor.run {
                        storage = newValue
                    }
                }
            }
        }
    }

    public var projectedValue: Bool {
        Task {
            let result = await validator.validate(storage)
            return result.isSuccess
        }.result?.isSuccess ?? false
    }

    public init(wrappedValue: String = "") {
        self.storage = wrappedValue
    }
}

/// Property wrapper for formatted IBAN display
@propertyWrapper
public struct FormattedIBAN {
    private var storage: String = ""
    private let validator = IBANValidator()

    public var wrappedValue: String {
        get { validator.format(storage) }
        set { storage = validator.removeFormatting(newValue) }
    }

    public var projectedValue: String {
        storage // Returns unformatted version
    }

    public init(wrappedValue: String = "") {
        self.storage = validator.removeFormatting(wrappedValue)
    }
}

// MARK: - SwiftUI Integration

#if canImport(SwiftUI)
/// Observable object for IBAN validation in SwiftUI
@available(iOS 13.0, macOS 10.15, *)
public class IBANValidationModel: ObservableObject {
    @Published public var iban: String = "" {
        didSet {
            validateIBAN()
        }
    }

    @Published public var isValid: Bool = false
    @Published public var validationError: IBANError?
    @Published public var formattedIBAN: String = ""

    private let validator = IBANValidator()

    public init() {}

    private func validateIBAN() {
        guard !iban.isEmpty else {
            isValid = false
            validationError = nil
            formattedIBAN = ""
            return
        }

        Task {
            let result = await validator.validate(iban)
            await MainActor.run {
                switch result {
                case .success:
                    self.isValid = true
                    self.validationError = nil
                    self.formattedIBAN = self.validator.format(self.iban)
                case .failure(let error):
                    self.isValid = false
                    self.validationError = error
                    self.formattedIBAN = ""
                }
            }
        }
    }

    public func format() -> String {
        return validator.format(iban)
    }

    public func clean() -> String {
        return validator.removeFormatting(iban)
    }
}

/// SwiftUI TextField for IBAN input with validation
@available(iOS 13.0, macOS 10.15, *)
public struct IBANTextField: View {
    @ObservedObject private var model = IBANValidationModel()
    @Binding private var text: String
    private let placeholder: String

    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder, text: $model.iban)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.allCharacters)
                .disableAutocorrection(true)
                .onChange(of: model.iban) { newValue in
                    text = newValue
                }
                .onChange(of: text) { newValue in
                    if model.iban != newValue {
                        model.iban = newValue
                    }
                }

            if let error = model.validationError {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .font(.caption)
            } else if model.isValid && !model.iban.isEmpty {
                Text("Valid IBAN: \(model.formattedIBAN)")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
    }
}
#endif

// MARK: - Combine Integration

#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, *)
extension IBANValidator {
    /// Validates IBAN using Combine
    /// - Parameter iban: IBAN string to validate
    /// - Returns: Publisher that emits validation result
    public func validatePublisher(_ iban: String) -> AnyPublisher<Result<Void, IBANError>, Never> {
        Future { promise in
            Task {
                let result = await self.validate(iban)
                promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }

    /// Creates IBAN using Combine
    public func createIBANPublisher(accountNumber: String, bankCode: String? = nil, countryCode: String) -> AnyPublisher<Result<String, IBANError>, Never> {
        Future { promise in
            Task {
                let result = await self.createIBAN(accountNumber: accountNumber, bankCode: bankCode, countryCode: countryCode)
                promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }
}
#endif

// MARK: - Extensions

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}