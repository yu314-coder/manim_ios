// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Manim",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Manim",
            targets: ["Manim"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pvieito/PythonKit.git", branch: "master")
    ],
    targets: [
        .target(
            name: "Manim",
            dependencies: [
                "PythonKit"
            ],
            path: "manim",
            resources: [
                .copy("../Python.xcframework"),
                .copy("../Frameworks")
            ]
        )
    ]
)
