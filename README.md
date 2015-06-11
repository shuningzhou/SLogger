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

## Reading & Removing History Logs
```objective-c
[[SLogger sharedLogger] getContentUpTo:100 * SLOG_KB completionHandler:^(NSString *content, NSArray *filesRead) {
        
        NSLog(@"Content = %@", content);
        NSLog(@"FilesRead = %@", filesRead);
        
        [[SLogger sharedLogger] removeFiles:filesRead];
    }];
```
