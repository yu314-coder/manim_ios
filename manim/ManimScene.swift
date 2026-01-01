import Foundation
import PythonKit

public class ManimScene {
    private let manim: PythonObject
    private var scene: PythonObject?
    private var mobjects: [PythonObject] = []

    internal init(manim: PythonObject) {
        self.manim = manim
        self.scene = manim.Scene()
    }

    // MARK: - Basic Shapes

    public func createCircle(radius: Double = 1.0, color: String = "BLUE") -> ManimObject {
        let circle = manim.Circle(radius: radius, color: manim.Color[color])
        return ManimObject(pythonObject: circle, scene: self)
    }

    public func createSquare(sideLength: Double = 2.0, color: String = "GREEN") -> ManimObject {
        let square = manim.Square(side_length: sideLength, color: manim.Color[color])
        return ManimObject(pythonObject: square, scene: self)
    }

    public func createText(_ text: String, fontSize: Double = 48) -> ManimObject {
        let textObj = manim.Text(text, font_size: fontSize)
        return ManimObject(pythonObject: textObj, scene: self)
    }

    public func createMathTex(_ latex: String) -> ManimObject {
        let mathTex = manim.MathTex(latex)
        return ManimObject(pythonObject: mathTex, scene: self)
    }

    // MARK: - Scene Management

    public func add(_ object: ManimObject) {
        scene?.add(object.pythonObject)
        mobjects.append(object.pythonObject)
    }

    public func remove(_ object: ManimObject) {
        scene?.remove(object.pythonObject)
        mobjects.removeAll { Python.id($0) == Python.id(object.pythonObject) }
    }

    public func clear() {
        scene?.clear()
        mobjects.removeAll()
    }

    // MARK: - Animations

    public func play(_ animation: ManimAnimation, runTime: Double = 1.0) {
        scene?.play(animation.pythonObject, run_time: runTime)
    }

    public func wait(_ duration: Double = 1.0) {
        scene?.wait(duration)
    }

    internal var pythonScene: PythonObject? {
        return scene
    }
}
