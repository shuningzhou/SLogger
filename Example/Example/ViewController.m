//
//  ViewController.m
//  Example
//
//  Created by shuning zhou on 2015-06-11.
//

#import "ViewController.h"
#import "SLogger.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SLogger sharedLogger].maxNumberOfLogFiles = 3;
    [SLogger sharedLogger].maxSizeOfLogFile = 50 * SLOG_KB;
    [SLogger sharedLogger].logLevel = SLogLevelVerbose;
    
    NSString *format = @"Logger level = %@";
    
    SLogError(format, @"Error");
    SLogInfo(format, @"Info");
    SLogVerbose(format, @"Verbose");
    
    [[SLogger sharedLogger] getContentUpTo:100 * SLOG_KB completionHandler:^(NSString *content, NSArray *filesRead) {
        
        NSLog(@"Content = %@", content);
        NSLog(@"FilesRead = %@", filesRead);
        
        [[SLogger sharedLogger] removeFiles:filesRead];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
