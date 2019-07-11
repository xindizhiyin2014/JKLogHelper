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
@property (nonatomic,strong) NSLock *lock;
@property (nonatomic,assign) BOOL isWritting; ///< is writting log to file
@property (nonatomic,assign) NSInteger maxLogs;

@end

@implementation JKLogHelper

static JKLogHelper *_logHelper = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _logHelper = [[self alloc] init];
        _logHelper.lock = [[NSLock alloc] init];
        _logHelper.maxLogs = 30;
    });
    return _logHelper;
}

+ (void)start{
    [[JKLogHelper shareInstance].lock lock];
    if (![JKLogHelper shareInstance].isWritting) {
        NSArray *logFiles = [self getLogFiles];
        if (logFiles.count == [JKLogHelper shareInstance].maxLogs) {
            NSString *fileName = logFiles.firstObject;
            NSString *logFilePath = [NSString stringWithFormat:@"%@/%@.log",[self folderPath],fileName];
            [JKSandBoxManager deleteFile:logFilePath];
        }
        JKDateSeperator *seperator = [JKDateSeperator new];
        seperator.yyyySeperator = @"-";
        seperator.MMSeperator = @"-";
        seperator.ddSeperator = @"-";
        seperator.HHSeperator = @"-";
        seperator.mmSeperator = @"-";
        
        NSString *fileName = [JKDateHelper fullTimeStrFromDate:[NSDate date] seperator:seperator];
        NSString *logFilePath = [NSString stringWithFormat:@"%@/%@.log",[self folderPath],fileName];
        freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
        [JKLogHelper shareInstance].isWritting = YES;
    }

    [[JKLogHelper shareInstance].lock unlock];

}

+ (void)configMaxLogFiles:(NSInteger)maxLogs{
    [[JKLogHelper shareInstance].lock lock];
    [JKLogHelper shareInstance].maxLogs = maxLogs;
    [[JKLogHelper shareInstance].lock unlock];
}


+ (void)deleteAllLogFiles{
    [JKSandBoxManager deleteFile:[self folderPath]];
}

+ (NSArray <NSString *>*)getLogFiles{
    NSArray *files = [JKSandBoxManager filesWithFolderAtPath:[JKLogHelper shareInstance].folderPath];
    return files;
}

+ (NSString *)folderPath{
    return [JKLogHelper shareInstance].folderPath;
}

+ (void)viewLog{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    JKLogFileListViewController *logFileListVC = [JKLogFileListViewController new];
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:logFileListVC];
    [vc presentViewController:naVC animated:YES completion:nil];
}

+ (NSString *)lastCallMethod{
    NSArray *symbols = [NSThread callStackSymbols];
    NSInteger maxCount = symbols.count;
    NSString *secondSymbol = maxCount > 2 ? symbols[2] : (maxCount > 1 ? symbols[1] : [symbols firstObject]);
    if (secondSymbol.length == 0) {
        return @"";
    }
    
    NSString *pattern = @"[+-]\\[.{0,}\\]";
    NSError *error;
    NSRegularExpression *express = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return @"";
    }
    
    NSTextCheckingResult *checkResult = [[express matchesInString:secondSymbol options:NSMatchingReportCompletion range:NSMakeRange(0, secondSymbol.length)] lastObject];
    NSString *findStr = [secondSymbol substringWithRange:checkResult.range];
    return findStr ?: @"";
}


#pragma mark - - - - getter - - - -
- (NSString *)folderPath{
    if (!_folderPath) {
        _folderPath = [JKSandBoxManager createDocumentsFilePathWithFolderName:@"JKLogHelper_logs"];
    }
    return _folderPath;
}

@end
