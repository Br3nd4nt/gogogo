//
//  Dependencies.swift
//  GoGoGo
//
//  Created by br3nd4nt on 10.07.2026.
//

import Foundation
import Puppy
import Swinject

final class Dependencies {
    @MainActor static let shared = Dependencies()
    private let container = Container()
    
    private let appIdentifier = "com.br3nd4nt.gogogo"
    
    private init() {
        setupDependencies()
    }
    
    private func setupDependencies() {
        // Logging
        let puppy: Puppy
        let formatter = LogFormatter()
        
        let console = ConsoleLogger(appIdentifier + ".console", logLevel: .info, logFormat: formatter)
        
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = directoryURL.appendingPathComponent("GoGoGo.log")
        
        do {
            let file = try FileLogger(
                appIdentifier,
                logLevel: .debug,
                logFormat: formatter,
                fileURL: fileURL,
                filePermission: "600"
            )
            puppy = Puppy(loggers: [console, file])
            puppy.info("Debug logs path: \(fileURL)")
        } catch {
            puppy = Puppy(loggers: [console])
            logger.warning("Couldnt create file logger: \(error)")
            
        }
        
        container.register(Puppy.self) { _ in
            puppy
        }
        .inObjectScope(.container)
    }
    
    // MARK: - Resolution Methods
    
    /// Resolve a service by type
    func resolve<T>(_ serviceType: T.Type) -> T? {
        container.resolve(serviceType)
    }
    
    // swiftlint:disable force_unwrapping
    
    /// Resolve a service by type (non-optional, will crash if not found)
    func resolve<T>(_ serviceType: T.Type) -> T {
        container.resolve(serviceType)!
    }
    
    // MARK: - Convenience Methods
    
    var logger: Puppy {
        resolve(Puppy.self)!
    }
    // swiftlint: enable force_unwrapping
}
