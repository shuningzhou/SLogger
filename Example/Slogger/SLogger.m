//
//  SLogger.m
//
//  Created by shuning zhou on 2015-06-11.
//

#import "SLogger.h"

@interface SLogger ()

@property (nonatomic, strong) NSString *folderPath;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSString *currentLogFileName;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SLogger

+ (instancetype)sharedLogger;
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
                  {
                      sharedManager = [self new];
                  });
    
    return sharedManager;
}

- (id)init;
{
    self = [super init];
    
    if (self)
    {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd(HH:mm:ss)";
        self.logLevel = SLogLevelVerbose;
        self.maxSizeOfLogFile = 1024 * 50;
        self.maxNumberOfLogFiles = 5;
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue setMaxConcurrentOperationCount:1];
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:SLOG_FOLER_NAME];
        self.folderPath = folderPath;
        
        [self createFolderIfDoesNotExist];
        
        self.currentLogFileName = [self getCurrentLogFileName];
    }
    
    return self;
}

- (void)logAtLogLevel:(SLogLevel)level format:(NSString *)format, ...;
{
    if (self.logLevel < level)
    {
        return;
    }
    
    va_list args;
    va_start(args, format);
    NSString *text = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"<%lu>%@",(unsigned long)self.operationQueue.operationCount, text);
    
    [self.operationQueue addOperationWithBlock:^{
        
        if ([self currentFileIsFull])
        {
            self.currentLogFileName = [self makeNewLogFile];
        }
        
        NSString *timeStamppedText = [NSString stringWithFormat:@"%@: %@\n", [self.dateFormatter stringFromDate:[NSDate date]], text];
        
        NSFileHandle *fileHandle =[NSFileHandle fileHandleForWritingAtPath:[self getCurrentLogFilePath]];
        
        [fileHandle seekToEndOfFile];
        
        [fileHandle writeData:[timeStamppedText dataUsingEncoding:NSUTF8StringEncoding]];
        
        [fileHandle closeFile];
        
    }];
}

- (void)removeFiles:(NSArray*)filesToRemove;
{
    [self.operationQueue addOperationWithBlock:^{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        for (NSString *file in filesToRemove)
        {
            [fileManager removeItemAtPath:[self.folderPath stringByAppendingPathComponent:file] error:nil];
        }
    }];
}

- (void)getContentUpTo:(long)size completionHandler:(void (^)(NSString* content, NSArray *filesRead))handler;
{
    [self.operationQueue addOperationWithBlock:^{
        
        NSArray *sortedFiles = [self sortedLogFilesFromOldToNew];
        
        NSMutableString *content = [NSMutableString string];
        NSMutableArray *filesRead = [NSMutableArray array];
        
        for (NSString *file in sortedFiles)
        {
            NSString *filePath = [self.folderPath stringByAppendingPathComponent:file];
            NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            [content appendString:fileContent];
            [filesRead addObject:file];
            
            NSUInteger bytes = [content lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            
            if (bytes + self.maxSizeOfLogFile > size)
            {
                break;
            }
        }
        
        handler([content copy], [filesRead copy]);
    }];
}

#pragma mark Helper

- (void)createFolderIfDoesNotExist;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isFolder = NO;
    BOOL folderExists = [fileManager fileExistsAtPath:self.folderPath isDirectory:&isFolder];
    
    if (!folderExists)
    {
        [fileManager createDirectoryAtPath:self.folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSString *)getCurrentLogFilePath;
{
    return [self.folderPath stringByAppendingPathComponent:self.currentLogFileName];
}

- (NSString *)getCurrentLogFileName;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:self.folderPath error:nil];
    
    if (logFiles.count == 0)
    {
        return [self makeNewLogFile];
    }
    else
    {
        NSArray *sortedFiles = [self sortedLogFilesFromOldToNew];
        NSString *fileName = [sortedFiles lastObject];
        
        return fileName;
    }
}

- (BOOL)currentFileIsFull;
{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self getCurrentLogFilePath] error:nil];
    
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    long long fileSize = [fileSizeNumber longLongValue];
    
    if (fileSize < self.maxSizeOfLogFile)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (NSString*)makeNewLogFile;
{
    NSDate *now = [NSDate date];
    NSString *fileName = [self.dateFormatter stringFromDate:now];
    [[NSFileManager defaultManager] createFileAtPath:[self.folderPath stringByAppendingPathComponent:fileName] contents:nil attributes:nil];
    
    [self removeOldLogFileIfNecessary];
    
    return fileName;
}

- (void)removeOldLogFileIfNecessary;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:self.folderPath error:nil];
    
    if (logFiles.count > self.maxNumberOfLogFiles)
    {
        NSArray *sortedFiles = [self sortedLogFilesFromOldToNew];
        NSString *fileName = [sortedFiles firstObject];
        
        [fileManager removeItemAtPath:[self.folderPath stringByAppendingPathComponent:fileName] error:nil];
    }
}

- (NSArray*)sortedLogFilesFromOldToNew;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:self.folderPath error:nil];
    
    NSArray *sortedFiles;
    sortedFiles = [logFiles sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *dateA = [self.dateFormatter dateFromString:a];
        NSDate *dateB = [self.dateFormatter dateFromString:b];
        return [dateA compare:dateB];
    }];
    
    return sortedFiles;
}

@end
