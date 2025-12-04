import Foundation

struct DefaultJsonTransformUseCase: JsonTransformUseCase {
    init() {}

    func execute(_ request: JsonTransformRequest) -> JsonTransformResult {
        switch request.mode {
        case .format:
            return format(jsonString: request.rawText)
        case .minify:
            return minify(jsonString: request.rawText)
        case .escape:
            return escape(raw: request.rawText)
        case .unescape:
            return unescape(raw: request.rawText)
        }
    }

    private func format(jsonString: String) -> JsonTransformResult {
        parse(jsonString: jsonString, options: [.prettyPrinted])
    }

    private func minify(jsonString: String) -> JsonTransformResult {
        parse(jsonString: jsonString, options: [])
    }

    private func escape(raw: String) -> JsonTransformResult {
        let escaped: String
        if let data = try? JSONEncoder().encode(raw),
           let encoded = String(data: data, encoding: .utf8) {
            // JSONEncoder wraps string in quotes, remove them.
            escaped = String(encoded.dropFirst().dropLast())
        } else {
            return JsonTransformResult(output: "", isValidJson: false, errorDescription: "Failed to escape text.")
        }
        return JsonTransformResult(output: escaped, isValidJson: true, errorDescription: nil)
    }

    private func unescape(raw: String) -> JsonTransformResult {
        let wrapped = "\"\(raw)\""
        guard let data = wrapped.data(using: .utf8) else {
            return JsonTransformResult(output: "", isValidJson: false, errorDescription: "Invalid UTF-8 input.")
        }
        if let decoded = try? JSONDecoder().decode(String.self, from: data) {
            return JsonTransformResult(output: decoded, isValidJson: true, errorDescription: nil)
        } else {
            return JsonTransformResult(output: "", isValidJson: false, errorDescription: "Failed to unescape text.")
        }
    }

    private func parse(jsonString: String, options: JSONSerialization.WritingOptions) -> JsonTransformResult {
        guard !jsonString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return JsonTransformResult(output: "", isValidJson: false, errorDescription: "Input is empty.")
        }
        guard let data = jsonString.data(using: .utf8) else {
            return JsonTransformResult(output: "", isValidJson: false, errorDescription: "Invalid UTF-8 input.")
        }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let formattedData = try JSONSerialization.data(withJSONObject: object, options: options)
            guard let formattedString = String(data: formattedData, encoding: .utf8) else {
                return JsonTransformResult(output: "", isValidJson: false, errorDescription: "Unable to encode output.")
            }
            return JsonTransformResult(output: formattedString, isValidJson: true, errorDescription: nil)
        } catch {
            return JsonTransformResult(output: "", isValidJson: false, errorDescription: error.localizedDescription)
        }
    }
}
