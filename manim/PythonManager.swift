import Foundation
import PythonKit

public class PythonManager {
    public static let shared = PythonManager()

    private var isPythonInitialized = false
    private var pythonVersion: String?

    private init() {}

    public func initialize() throws {
        guard !isPythonInitialized else { return }

        // IMPORTANT: Set Python library path BEFORE any Python calls
        setPythonLibraryPath()

        // Configure Python paths for bundled Python.xcframework
        configurePythonEnvironment()

        // Initialize Python runtime
        #if targetEnvironment(simulator)
        // For simulator, we need to ensure the simulator slice is used
        print("[PythonManager] Initializing for simulator")
        #else
        print("[PythonManager] Initializing for device")
        #endif

        // PythonKit initializes Python automatically on first use
        // Just verify Python is working by importing sys
        do {
            let sys = try Python.attemptImport("sys")
            pythonVersion = String(describing: sys.version)
            print("[PythonManager] Python initialized: \(pythonVersion ?? "unknown")")
            isPythonInitialized = true
        } catch {
            throw PythonError.initializationFailed("Could not initialize Python runtime")
        }
    }

    private func setPythonLibraryPath() {
        // Determine platform-specific path
        #if targetEnvironment(simulator)
        let platformPath = "ios-arm64_x86_64-simulator"
        #else
        let platformPath = "ios-arm64"
        #endif

        // Try to find Python.framework in various locations
        var pythonLibPath: String?

        // For Swift Package Manager, resources are in a different location
        // Try module bundle first (for SPM)
        let moduleName = "Manim_Manim"
        if let bundlePath = Bundle.main.path(forResource: moduleName, ofType: "bundle"),
           let bundle = Bundle(path: bundlePath) {
            print("[PythonManager] Found SPM bundle: \(bundlePath)")

            // Try to find Python.xcframework in the bundle
            if let resourcePath = bundle.resourcePath {
                let spmPaths = [
                    "\(resourcePath)/Python.xcframework/\(platformPath)/Python.framework/Python",
                    "\(bundlePath)/Python.xcframework/\(platformPath)/Python.framework/Python"
                ]

                for path in spmPaths {
                    if FileManager.default.fileExists(atPath: path) {
                        pythonLibPath = path
                        print("[PythonManager] Found Python in SPM bundle at: \(path)")
                        break
                    }
                }
            }
        }

        // If not found in SPM bundle, try main bundle locations
        if pythonLibPath == nil {
            if let frameworkPath = Bundle.main.path(forResource: "Python", ofType: "framework", inDirectory: "Frameworks/Python.xcframework/\(platformPath)") {
                pythonLibPath = "\(frameworkPath)/Python"
                print("[PythonManager] Found Python in Frameworks/")
            }
            else if let resourcePath = Bundle.main.resourcePath {
                let altPaths = [
                    "\(resourcePath)/Python.xcframework/\(platformPath)/Python.framework/Python",
                    "\(resourcePath)/Frameworks/Python.xcframework/\(platformPath)/Python.framework/Python",
                    "\(resourcePath)/\(moduleName).bundle/Python.xcframework/\(platformPath)/Python.framework/Python"
                ]

                for path in altPaths {
                    if FileManager.default.fileExists(atPath: path) {
                        pythonLibPath = path
                        print("[PythonManager] Found Python in main bundle at: \(path)")
                        break
                    }
                }
            }
        }

        if let libPath = pythonLibPath {
            setenv("PYTHON_LIBRARY", libPath, 1)
            print("[PythonManager] Set PYTHON_LIBRARY to: \(libPath)")
        } else {
            print("[PythonManager] ERROR: Python library not found in any bundle location")
            print("[PythonManager] Platform: \(platformPath)")

            // Debug: List what's actually in the bundle
            if let resourcePath = Bundle.main.resourcePath {
                print("[PythonManager] Resource path: \(resourcePath)")
                if let contents = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                    print("[PythonManager] Bundle contents: \(contents.prefix(10))")
                }
            }

            // Also check SPM bundle
            if let bundlePath = Bundle.main.path(forResource: moduleName, ofType: "bundle"),
               let bundle = Bundle(path: bundlePath),
               let bundleResourcePath = bundle.resourcePath {
                print("[PythonManager] SPM bundle resource path: \(bundleResourcePath)")
                if let bundleContents = try? FileManager.default.contentsOfDirectory(atPath: bundleResourcePath) {
                    print("[PythonManager] SPM bundle contents: \(bundleContents.prefix(20))")
                }
            }
        }
    }

    private func configurePythonEnvironment() {
        // Find the Python framework bundle
        #if targetEnvironment(simulator)
        let platformPath = "ios-arm64_x86_64-simulator"
        #else
        let platformPath = "ios-arm64"
        #endif

        // The Python.xcframework should be in the app bundle
        if let frameworkPath = Bundle.main.path(forResource: "Python", ofType: "framework", inDirectory: "Frameworks/Python.xcframework/\(platformPath)") {
            let pythonHome = frameworkPath
            let pythonLib = "\(pythonHome)/lib"
            let pythonVersion = "python3.14"
            let sitePackages = "\(pythonLib)/\(pythonVersion)/site-packages"

            // Set environment variables
            setenv("PYTHONHOME", pythonHome, 1)
            setenv("PYTHONPATH", "\(pythonLib)/\(pythonVersion):\(sitePackages)", 1)
            setenv("PYTHONOPTIMIZE", "1", 1)  // Use optimized bytecode
            setenv("PYTHONDONTWRITEBYTECODE", "1", 1)  // Don't write .pyc files

            print("[PythonManager] PYTHONHOME: \(pythonHome)")
            print("[PythonManager] PYTHONPATH: \(pythonLib)/\(pythonVersion):\(sitePackages)")
        } else {
            print("[PythonManager] Warning: Could not find Python.framework in bundle")
            print("[PythonManager] Falling back to system Python (this may not work)")
        }
    }

    public func importModule(_ name: String) throws -> PythonObject {
        try initialize()

        do {
            let module = try Python.attemptImport(name)
            print("[PythonManager] Successfully imported module: \(name)")
            return module
        } catch {
            print("[PythonManager] Failed to import module: \(name)")
            throw PythonError.moduleNotFound(name)
        }
    }

    public func importManim() throws -> PythonObject {
        do {
            return try importModule("manim")
        } catch {
            throw PythonError.manimNotAvailable(
                "Manim is not installed. See INSTALLATION.md for setup instructions."
            )
        }
    }

    public var version: String? {
        return pythonVersion
    }

    deinit {
        // PythonKit handles cleanup automatically
        // No need to call Py_Finalize manually
    }
}

public enum PythonError: Error, LocalizedError {
    case moduleNotFound(String)
    case manimNotAvailable(String)
    case initializationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .moduleNotFound(let name):
            return "Python module '\(name)' not found"
        case .manimNotAvailable(let message):
            return message
        case .initializationFailed(let message):
            return "Python initialization failed: \(message)"
        }
    }
}
