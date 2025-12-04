import Testing
@testable import Kitty

struct JsonTransformUseCaseTests {
    @Test
    func formatValidJson() {
        let useCase = DefaultJsonTransformUseCase()
        let request = JsonTransformRequest(rawText: "{\"a\":1}", mode: .format)
        let result = useCase.execute(request)

        #expect(result.isValidJson)
        #expect(result.errorDescription == nil)
        #expect(result.output.contains("\n"))
    }

    @Test
    func formatInvalidJson() {
        let useCase = DefaultJsonTransformUseCase()
        let request = JsonTransformRequest(rawText: "{a:1}", mode: .format)
        let result = useCase.execute(request)

        #expect(!result.isValidJson)
        #expect(result.errorDescription != nil)
    }

    @Test
    func escapeAndUnescape() {
        let useCase = DefaultJsonTransformUseCase()
        let text = #"{"key":"value"}"#

        let escaped = useCase.execute(.init(rawText: text, mode: .escape))
        #expect(escaped.isValidJson)
        #expect(escaped.errorDescription == nil)
        #expect(escaped.output != text)

        let unescaped = useCase.execute(.init(rawText: escaped.output, mode: .unescape))
        #expect(unescaped.output == text)
    }
}
