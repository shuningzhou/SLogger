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
    [SLogger sharedLogger].maxSizeOfLogFile = 50 * 1024;
    [SLogger sharedLogger].logLevel = SLogLevelVerbose;
    
    NSString *format = @"Logger level = %@";
    
    SLogError(format, @"Error");
    SLogInfo(format, @"Info");
    SLogVerbose(format, @"Veerbose");
    
    [[SLogger sharedLogger] getContentUpTo:10 * 1024 completionHandler:^(NSString *content, NSArray *filesRead) {
        
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
