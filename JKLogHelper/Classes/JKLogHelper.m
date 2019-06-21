//
//  JKLogHelper.m
//  JKLogHelper
//
//  Created by JackLee on 2019/6/20.
//

#import "JKLogHelper.h"
#import "JKLogFileListViewController.h"
#import <JKSandBoxManager/JKSandBoxManager.h>
#import <JKDateHelper/JKDateHelper.h>


@interface JKLogHelper()

@property (nonatomic,copy) NSString *folderPath;

@end

@implementation JKLogHelper
static JKLogHelper *_logHelper = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _logHelper = [[self alloc] init];
    });
    return _logHelper;
}

+ (void)start{
    NSString *fileName = [JKDateHelper time]
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
}

+ (void)end{
    
}

+ (void)deleteAllLogFiles{
    [JKSandBoxManager deleteFile:[JKLogHelper shareInstance].folderPath];
//    NSArray *files = [self getLogFiles];
//    for (NSString *fileName in files) {
//        NSString *filePath = [NSString stringWithFormat:@"%@/%@",[JKLogHelper shareInstance].folderPath,fileName];
//        [JKSandBoxManager deleteFile:filePath];
//    }
}

+ (NSArray <NSString *>*)getLogFiles{
    NSArray *files = [JKSandBoxManager filesWithFolderAtPath:[JKLogHelper shareInstance].folderPath];
    return files;
}

+ (void)viewLog{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    JKLogFileListViewController *logileListVC = [JKLogFileListViewController new];
    [vc presentViewController:logileListVC animated:YES completion:nil];
}

#pragma mark - - - - lazyLoad - - - -
- (NSString *)folderPath{
    if (!_folderPath) {
        _folderPath = [JKSandBoxManager createDocumentsFilePathWithFolderName:@"JKLogHelper_logs"];
    }
    return _folderPath;
}

@end
