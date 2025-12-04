protocol JsonTransformUseCase: Sendable {
    func execute(_ request: JsonTransformRequest) -> JsonTransformResult
}
