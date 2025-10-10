
import Foundation

// MARK: - Modern ISO7064 Implementation

public enum ISO7064 {
    private static let validCharacterSet = CharacterSet.decimalDigits
    private static let maxChunkSize = 9
    private static let minProcessingLength = 3
    private static let modulus = 97

    public enum ValidationError: Error, LocalizedError {
        case invalidCharacters
        case emptyInput
        case processingError

        public var errorDescription: String? {
            switch self {
            case .invalidCharacters:
                return "Input contains non-numeric characters"
            case .emptyInput:
                return "Input string is empty"
            case .processingError:
                return "Error occurred during MOD-97 processing"
            }
        }
    }

    /// Calculates MOD-97 checksum according to ISO 7064
    /// - Parameter input: Numeric string to process
    /// - Returns: MOD-97 result
    /// - Throws: ValidationError for invalid input
    public static func mod97(_ input: String) throws -> Int {
        guard !input.isEmpty else {
            throw ValidationError.emptyInput
        }

        guard input.rangeOfCharacter(from: validCharacterSet.inverted) == nil else {
            throw ValidationError.invalidCharacters
        }

        var remainingInput = input

        while remainingInput.count >= minProcessingLength {
            let chunkSize = min(remainingInput.count, maxChunkSize)
            let endIndex = remainingInput.index(remainingInput.startIndex, offsetBy: chunkSize)
            let chunkString = String(remainingInput[remainingInput.startIndex..<endIndex])

            guard let chunk = Int(chunkString) else {
                throw ValidationError.processingError
            }

            let remainder = chunk % modulus
            let nextChunk = remainingInput[endIndex...]

            remainingInput = "\(remainder)\(nextChunk)"
        }

        guard let result = Int(remainingInput) else {
            throw ValidationError.processingError
        }

        return result
    }

    // MARK: - Legacy Support

    @available(*, deprecated, message: "Use mod97(_:) throws instead")
    public static func MOD97_10(_ input: String) -> Int {
        do {
            return try mod97(input)
        } catch {
            return NSNotFound
        }
    }
}
