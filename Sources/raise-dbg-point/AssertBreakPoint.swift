/// File: AssertBreakPoint.swift --------------------------------------------------
///
/// This file will inject an asserter global function that can be used to
/// assert a debug breakpoint (stop execution and show stack) when called
/// and the application is running with a debugger attached.  When running
/// with out a debugger present it will print a message to standard error.

import Foundation
import OSLog

// private global variables, these are needed because the C function 
//     pointer passed in to `signal` handler require a global scope
//     otherwise it does not know when to release the memory for them
private var __assertBreakPointMessage = Data()
private var __assertBreakPointWriter: AssertBreakPointWriteable = FileHandle.standardError

/// public protocol AssertBreakPointWriteable allows a pass in for where the asserter 
///   function should log an error when no debugger is attached to the 
///   application.
public protocol AssertBreakPointWriteable {
/// used to write data when an asserter is called
///  - Parameters:
///     - data: data to write out 
    func write(_ data: Data)
}

/// extension to FileHandle to allow a FileHandle to be used as a 
/// AssertBreakPointWriteable so that standardOut or standardError FileHandle can 
/// be used as an AssertBreakPointWriteable
extension FileHandle: AssertBreakPointWriteable {}

/// extension to Logger to allow a Logger to be used as an
/// AssertBreakPointWriteable so that OSLog be used as an AssertBreakPointWriteable
extension Logger: AssertBreakPointWriteable {
    public func write(_ data: Data) {
        guard let msg = String(data: data, encoding: .utf8) else {
            preconditionFailure("unable to convert data to utf8 string")
        }
        critical("\(msg, privacy: .public)")
    }
}

/// Assert a message to the assertBreakPoint when no debugger is attached or 
/// stop on a debug breakpoint if there is a debugger attached.
/// 
/// - Parameters:
///   - msg: String to be written to assertBreakPoint when no debugger is attached
///   writer: AssertBreakPointWriteable to write msg
///   - file: File that the asserter was called from
///   - line: Line number in file that asserter was called from
///   - function: Function that called the asserter
public func assertBreakPoint(
    _ msg: String,
    writer: AssertBreakPointWriteable = Logger(),
    _ file: String = #file,
    _ line: Int = #line,
    _ function: String = #function
) {
    // format the message
    let msg = "\(msg) (function: \(function) [\(file), \(line)])\r\n"
    // convert message from UTF8 String to Data
    guard let data = msg.data(using: .utf8) else { 
        preconditionFailure("\(msg) is not a utf8 string") 
    }
    // assign the data to global message for C function usage
    __assertBreakPointMessage = data
    // assign the assertBreakPoint to global assertBreakPoint for C function usage
    __assertBreakPointWriter = writer
    // register to use our C function pointer for Signal Interrupt (SIGINT)
    //  LLDB and GDB will override when attached and the C function will not 
    //  be called
    signal(SIGINT) { sig in
        // make sure it is a SIGINT we are handling in the C function
        if sig == SIGINT {
            // use the global AssertBreakPointWriteable to write the global message
            __assertBreakPointWriter.write(__assertBreakPointMessage)
        }
    }
    // raise a Signal Interrupt to be handler by the registered C function 
    // above
    raise(SIGINT)
    // unregister our C function once done
    signal(SIGINT, SIG_DFL)
}
