# swift-raise-dbg-point

Inject an asserter global function that can be used to assert a debug breakpoint (stop execution and show stack) when called and the application is running with a debugger attached.  When running without a debugger present it will print a message to standard error.

## Use Case:

When you want to really let people know there is a problem that needs to be fixed, but you don't want to cause a crash when running outside a debugger like assertionFailure does.

## Running

To run directly from command line with `swift`

```bash
swift run
```

To run inside the debugger from command line with `lldb`.  This will allow you to see the debug breakpoint being triggered

```bash
# must build first
swift build
lldb .build/debug/raise-dbg-point
```

To run as a release build to see no-op

```bash
swift run -c release
```

You can also just load the project in Xcode, but remember you will not see the output if you use Xcode you will have to go to derived data and run from cmd if you want to see the trapping of the SIGINT from the command line.

### enjoy
