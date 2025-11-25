import Foundation
import Pipeline
import PipelineLoggingBinding
import BasicLogging

/// Keeps track of the severity i.e. the worst message type.
public final class ConcurrentSeverityTracker: SeverityTracker, @unchecked Sendable {
    
    private var _severity = InfoType.allCases.min()!
    
    /// Gets the current severity.
    public var value: InfoType {
        queue.sync {
            _severity
        }
    }
    
    internal let group = DispatchGroup()
    internal let queue: DispatchQueue
    
    public init(qualityOfService: DispatchQoS = .userInitiated) {
        queue = DispatchQueue(label: "SeverityTracker", qos: qualityOfService)
    }
    
    public func process(_ newSeverity: InfoType) {
        group.enter()
        self.queue.sync {
            if newSeverity > _severity {
                _severity = newSeverity
            }
            self.group.leave()
        }
    }
    
    /// Wait until all logging is done.
    public func wait() {
        group.wait()
    }
    
}

/// A logger that just prints to the standard output.
public final class LogEntryPrinter: Logger, @unchecked Sendable {
    
    public typealias Message = ExecutionLogEntry
    public typealias Mode = InfoType
    
    private let printLogger: PrintLogger<ExecutionLogEntry,PrintMode>
    
    public init(errorsToStandard: Bool = false) {
        printLogger = PrintLogger(errorsToStandard: errorsToStandard)
    }
    
    public func log(_ message: ExecutionLogEntry, withMode mode: InfoType? = nil) {
        if let mode, mode >= .error {
            printLogger.log(message, withMode: .error)
        } else {
            printLogger.log(message, withMode: .standard)
        }
        
    }
    
    public func close() throws {
        try printLogger.close()
    }
    
}

public enum PrintMode: Sendable {
    case standard
    case error
}

func printToErrorOut(_ message: CustomStringConvertible) {
    FileHandle.standardError.write(Data("\(message)\n".utf8))
}

/// A logger that just prints to the standard output.
public final class PrintLogger<Message: Sendable & CustomStringConvertible,Mode>: ConcurrentLogger<Message,PrintMode>, @unchecked Sendable {
    
    public typealias Message = Message
    public typealias Mode = PrintMode
    
    let errorsToStandard: Bool
    
    public init(errorsToStandard: Bool = false) {
        self.errorsToStandard = errorsToStandard
        super.init()
        loggingAction = { message,printMode in
            if errorsToStandard {
                print(message.description)
            } else {
                switch printMode {
                case .standard, nil:
                    print(message.description)
                case .error:
                    printToErrorOut(message.description)
                }
            }
        }
    }
    
}
