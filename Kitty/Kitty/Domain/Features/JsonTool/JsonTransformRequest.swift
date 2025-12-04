struct JsonTransformRequest: Sendable, Equatable {
    let rawText: String
    let mode: JsonTransformMode

    init(rawText: String, mode: JsonTransformMode) {
        self.rawText = rawText
        self.mode = mode
    }
}
