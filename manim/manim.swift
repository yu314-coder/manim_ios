//
//  manim.swift
//  manim
//
//  Created by Euler on 2025/12/30.
//

import Foundation

/// Main entry point for the Manim iOS library
public class Manim {
    public static let shared = Manim()

    private init() {}

    /// Initialize the Manim library
    /// - Throws: ManimError if initialization fails
    public func initialize() throws {
        try ManimBridge.shared.setup()
    }

    /// Create a new Manim scene
    /// - Returns: A new ManimScene instance
    /// - Throws: ManimError if scene creation fails
    public func createScene() throws -> ManimScene {
        return try ManimBridge.shared.createScene()
    }

    /// Get the current Manim version
    public var version: String? {
        return ManimBridge.shared.version
    }
}
