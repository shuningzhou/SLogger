# SimpleLogger

SimpleLogger is a logging module for iOS. 

## How To Use
Just replace NSLog statements with SLog statements.

## Configure The Logger
```objective-c
[SLogger sharedLogger].maxNumberOfLogFiles = 3;
[SLogger sharedLogger].maxSizeOfLogFile = 50 * SLOG_KB;
[SLogger sharedLogger].logLevel = SLogLevelVerbose;
```

## Read 
```objective-c
[SLogger sharedLogger].maxNumberOfLogFiles = 3;
[SLogger sharedLogger].maxSizeOfLogFile = 50 * SLOG_KB;
[SLogger sharedLogger].logLevel = SLogLevelVerbose;
```
