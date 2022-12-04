import OSLog
import Foundation

// Example of creating your own logger
let logger = Logger.init(subsystem: "raise-dbg-point", category: "Main")

// Example of using the assertDebug function
func run() {
    print("Rasing a debug breakpoint...")
    // show it in the console with base logger
    assertBreakPoint("print in base logger, if in a debugger this will trigger a breakpoint")
    // show it in standard error
    assertBreakPoint("print in stderr, if in a debugger this will trigger a breakpoint",
                     writer: FileHandle.standardError)
    // show it in the OSLog with our logger
    assertBreakPoint("print in our logger, if in a debugger this will trigger a breakpoint",
                     writer: logger)
    print("finished.")
}

run()
