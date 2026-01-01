import Foundation

/// Example usage of the Manim iOS library
public class ManimExample {

    /// Creates a simple circle animation
    public static func createCircleAnimation() throws -> URL {
        // Initialize Manim
        try Manim.shared.initialize()

        // Create a new scene
        let scene = try Manim.shared.createScene()

        // Create a circle
        let circle = scene.createCircle(radius: 1.0, color: "BLUE")

        // Add it to the scene
        scene.add(circle)

        // Animate the circle being created
        scene.play(circle.create(), runTime: 2.0)

        // Wait for 1 second
        scene.wait(1.0)

        // Render the scene
        let config = ManimRenderer.RenderConfig(
            quality: .medium,
            outputFormat: .mp4,
            fps: 30
        )

        return try ManimRenderer.renderToFile(
            scene: scene,
            filename: "circle_animation.mp4",
            config: config
        )
    }

    /// Creates a transformation animation
    public static func createTransformAnimation() throws -> URL {
        try Manim.shared.initialize()
        let scene = try Manim.shared.createScene()

        // Create a square
        let square = scene.createSquare(sideLength: 2.0, color: "GREEN")

        // Create a circle
        let circle = scene.createCircle(radius: 1.5, color: "RED")

        // Add square to scene
        scene.add(square)
        scene.play(square.fadeIn(), runTime: 1.0)

        // Transform square into circle
        scene.play(square.transformTo(circle), runTime: 2.0)
        scene.wait(1.0)

        // Fade out
        scene.play(circle.fadeOut(), runTime: 1.0)

        return try ManimRenderer.renderToFile(
            scene: scene,
            filename: "transform_animation.mp4"
        )
    }

    /// Creates a mathematical equation animation
    public static func createMathAnimation() throws -> URL {
        try Manim.shared.initialize()
        let scene = try Manim.shared.createScene()

        // Create mathematical text
        let equation = scene.createMathTex("E = mc^2")

        scene.add(equation)
        scene.play(equation.create(), runTime: 2.0)
        scene.wait(2.0)

        return try ManimRenderer.renderToFile(
            scene: scene,
            filename: "math_animation.mp4"
        )
    }

    /// Creates a complex animation with multiple objects
    public static func createComplexScene() throws -> URL {
        try Manim.shared.initialize()
        let scene = try Manim.shared.createScene()

        // Create title
        let title = scene.createText("Manim on iOS", fontSize: 60)
            .moveTo(x: 0, y: 3, z: 0)

        // Create shapes
        let circle = scene.createCircle(radius: 0.5, color: "BLUE")
            .shift(x: -2, y: 0, z: 0)

        let square = scene.createSquare(sideLength: 1.0, color: "GREEN")

        let triangle = scene.createCircle(radius: 0.5, color: "RED")
            .shift(x: 2, y: 0, z: 0)

        // Animate title
        scene.add(title)
        scene.play(title.fadeIn(), runTime: 1.0)
        scene.wait(0.5)

        // Animate shapes
        scene.add(circle)
        scene.add(square)
        scene.add(triangle)

        scene.play(circle.create(), runTime: 1.0)
        scene.play(square.create(), runTime: 1.0)
        scene.play(triangle.create(), runTime: 1.0)

        scene.wait(2.0)

        return try ManimRenderer.renderToFile(
            scene: scene,
            filename: "complex_scene.mp4"
        )
    }
}
