import Foundation
import PythonKit

public class ManimRenderer {
    public struct RenderConfig {
        public var quality: Quality
        public var outputFormat: OutputFormat
        public var backgroundColor: String
        public var fps: Int

        public init(
            quality: Quality = .medium,
            outputFormat: OutputFormat = .mp4,
            backgroundColor: String = "BLACK",
            fps: Int = 30
        ) {
            self.quality = quality
            self.outputFormat = outputFormat
            self.backgroundColor = backgroundColor
            self.fps = fps
        }
    }

    public enum Quality: String {
        case low = "l"
        case medium = "m"
        case high = "h"
        case uhd = "p"
    }

    public enum OutputFormat: String {
        case mp4 = "mp4"
        case mov = "mov"
        case gif = "gif"
        case png = "png"
    }

    public static func render(
        scene: ManimScene,
        outputPath: String,
        config: RenderConfig = RenderConfig()
    ) throws -> URL {
        guard let pythonScene = scene.pythonScene else {
            throw ManimError.notInitialized
        }

        // Set up config
        let manim = try PythonManager.shared.importManim()

        let configObj = manim.config
        configObj.quality = PythonObject(config.quality.rawValue)
        configObj.output_file = PythonObject(outputPath)
        configObj.background_color = manim.Color[PythonObject(config.backgroundColor)]
        configObj.frame_rate = PythonObject(config.fps)

        // Render the scene
        do {
            pythonScene.render()
        } catch {
            throw ManimError.renderFailed(String(describing: error))
        }

        let outputURL = URL(fileURLWithPath: outputPath)
        return outputURL
    }

    public static func renderToFile(
        scene: ManimScene,
        filename: String,
        config: RenderConfig = RenderConfig()
    ) throws -> URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let outputPath = documentsPath
            .appendingPathComponent(filename)
            .path

        return try render(scene: scene, outputPath: outputPath, config: config)
    }
}
