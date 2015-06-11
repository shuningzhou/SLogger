# SimpleLogger

SimpleLogger is a logging module for iOS. 

## How To Use
Just replace NSLog statements with SLog statements.

## Configuration
```objective-c
[SLogger sharedLogger].maxNumberOfLogFiles = 3;
[SLogger sharedLogger].maxSizeOfLogFile = 50 * SLOG_KB;
[SLogger sharedLogger].logLevel = SLogLevelVerbose;
```

## Logging
```objective-c
SLogError(@"Logging level = %@", @"Error");
SLogInfo(@"Logging level = %@", @"Info");
SLogVerbose(@"Logging level = %@", @"Verbose");
```

## Reading
```objective-c
[SLogger sharedLogger].maxNumberOfLogFiles = 3;
[SLogger sharedLogger].maxSizeOfLogFile = 50 * SLOG_KB;
[SLogger sharedLogger].logLevel = SLogLevelVerbose;
```
