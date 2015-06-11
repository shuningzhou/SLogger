//
//  SLogger.h
//
//  Created by shuning zhou on 2015-06-11.
//

#import <Foundation/Foundation.h>

#define SLOG_FOLER_NAME @"log"
#define SLOG_KB 1024
#define SLOG_DEFAULT_FILE_SIZE 100 //100KB
#define SLOG_DEFAULT_NUMBER_OF_FILES 5

#define SLogError(frmt, ...) [[SLogger sharedLogger] logAtLogLevel:SLogLevelError format:frmt, ##__VA_ARGS__];
#define SLogInfo(frmt, ...) [[SLogger sharedLogger] logAtLogLevel:SLogLevelInfo format:frmt, ##__VA_ARGS__];
#define SLogVerbose(frmt, ...) [[SLogger sharedLogger] logAtLogLevel:SLogLevelVerbose format:frmt, ##__VA_ARGS__];


typedef NS_ENUM(NSUInteger, SLogLevel) {
    SLogLevelOff       = 0,
    SLogLevelError     = 1,
    SLogLevelInfo     = 2,
    SLogLevelVerbose   = 3
};

@interface SLogger : NSObject

@property (nonatomic) double maxNumberOfLogFiles;
@property (nonatomic) long maxSizeOfLogFile;
@property (nonatomic) SLogLevel logLevel;

+ (instancetype)sharedLogger;

- (void)logAtLogLevel:(SLogLevel)level format:(NSString *)format, ...;
- (void)getContentUpTo:(long)size completionHandler:(void (^)(NSString* content, NSArray *filesRead))handler;
- (void)removeFiles:(NSArray*)filesToRemove;

@end

