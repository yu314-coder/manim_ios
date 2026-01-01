import Foundation
import PythonKit

public class ManimObject {
    internal let pythonObject: PythonObject
    private weak var scene: ManimScene?

    internal init(pythonObject: PythonObject, scene: ManimScene) {
        self.pythonObject = pythonObject
        self.scene = scene
    }

    // MARK: - Transformations

    public func shift(x: Double = 0, y: Double = 0, z: Double = 0) -> ManimObject {
        let _ = pythonObject.shift([x, y, z])
        return self
    }

    public func scale(_ factor: Double) -> ManimObject {
        let _ = pythonObject.scale(factor)
        return self
    }

    public func rotate(_ angle: Double) -> ManimObject {
        let _ = pythonObject.rotate(angle)
        return self
    }

    public func moveTo(x: Double = 0, y: Double = 0, z: Double = 0) -> ManimObject {
        let _ = pythonObject.move_to([x, y, z])
        return self
    }

    // MARK: - Styling

    public func setColor(_ color: String) -> ManimObject {
        if let manim = try? PythonManager.shared.importManim() {
            let _ = pythonObject.set_color(manim.Color[color])
        }
        return self
    }

    public func setOpacity(_ opacity: Double) -> ManimObject {
        let _ = pythonObject.set_opacity(opacity)
        return self
    }

    // MARK: - Animation Creation

    public func create() -> ManimAnimation {
        if let manim = try? PythonManager.shared.importManim() {
            return ManimAnimation(pythonObject: manim.Create(pythonObject))
        }
        fatalError("Manim not initialized")
    }

    public func fadeIn() -> ManimAnimation {
        if let manim = try? PythonManager.shared.importManim() {
            return ManimAnimation(pythonObject: manim.FadeIn(pythonObject))
        }
        fatalError("Manim not initialized")
    }

    public func fadeOut() -> ManimAnimation {
        if let manim = try? PythonManager.shared.importManim() {
            return ManimAnimation(pythonObject: manim.FadeOut(pythonObject))
        }
        fatalError("Manim not initialized")
    }

    public func transformTo(_ target: ManimObject) -> ManimAnimation {
        if let manim = try? PythonManager.shared.importManim() {
            return ManimAnimation(pythonObject: manim.Transform(pythonObject, target.pythonObject))
        }
        fatalError("Manim not initialized")
    }
}

public class ManimAnimation {
    internal let pythonObject: PythonObject

    internal init(pythonObject: PythonObject) {
        self.pythonObject = pythonObject
    }
}
