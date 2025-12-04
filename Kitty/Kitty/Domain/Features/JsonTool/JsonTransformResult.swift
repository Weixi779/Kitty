struct JsonTransformResult: Sendable, Equatable {
    let output: String
    let isValidJson: Bool
    let errorDescription: String?

    init(output: String, isValidJson: Bool, errorDescription: String?) {
        self.output = output
        self.isValidJson = isValidJson
        self.errorDescription = errorDescription
    }
}
