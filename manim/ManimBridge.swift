import Foundation
import PythonKit

public class ManimBridge {
    public static let shared = ManimBridge()

    private var manim: PythonObject?

    private init() {}

    public func setup() throws {
        manim = try PythonManager.shared.importManim()
    }

    public func createScene() throws -> ManimScene {
        guard let manim = manim else {
            throw ManimError.notInitialized
        }

        return ManimScene(manim: manim)
    }

    public var version: String? {
        guard let manim = manim else { return nil }
        return String(manim.__version__)
    }
}

public enum ManimError: Error, LocalizedError {
    case notInitialized
    case pythonError(String)
    case renderFailed(String)
    case invalidParameter(String)

    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Manim has not been initialized. Call Manim.shared.initialize() first."
        case .pythonError(let message):
            return "Python error: \(message)"
        case .renderFailed(let message):
            return "Render failed: \(message)"
        case .invalidParameter(let message):
            return "Invalid parameter: \(message)"
        }
    }
}
