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

static NSString * const kLogHelperFilesKey = @"kLogHelperFilesKey";
@interface JKLogHelper()

@property (nonatomic,copy) NSString *folderPath;
@property (nonatomic,strong) NSLock *lock;
@property (nonatomic,assign) BOOL isWritting; ///< is writting log to file
@property (nonatomic,assign) NSInteger maxLogs;
@property (nonatomic, strong) NSMutableArray *files;

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _maxLogs = 10;
        NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:kLogHelperFilesKey];
        if (!array) {
            array = @[];
        }
        _files = [NSMutableArray arrayWithArray:array];
    }
    return self;
}

+ (void)start{
    [[JKLogHelper shareInstance].lock lock];
    if (![JKLogHelper shareInstance].isWritting) {
        NSArray *logFiles = [self files];
        while (logFiles.count >= [JKLogHelper shareInstance].maxLogs) {
            NSString *fileName = logFiles.lastObject;
            NSString *logFilePath = [NSString stringWithFormat:@"%@/%@.log",[self folderPath],fileName];
            [JKSandBoxManager deleteFile:logFilePath];
            [[JKLogHelper shareInstance].files removeObject:fileName];
        }
        JKDateSeperator *seperator = [JKDateSeperator new];
        seperator.yyyySeperator = @"-";
        seperator.MMSeperator = @"-";
        seperator.ddSeperator = @"-";
        seperator.HHSeperator = @"-";
        seperator.mmSeperator = @"-";
        
        NSString *fileName = [JKDateHelper fullTimeStrFromDate:[NSDate date] seperator:seperator];
        [[JKLogHelper shareInstance].files insertObject:fileName atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:[JKLogHelper shareInstance].files forKey:kLogHelperFilesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *fileName in [JKLogHelper shareInstance].files) {
        NSString *logFilePath = [NSString stringWithFormat:@"%@/%@.log",[self folderPath],fileName];
        [array addObject:logFilePath];
    }
    return array;
}

+ (NSString *)folderPath{
    return [JKLogHelper shareInstance].folderPath;
}

+ (void)viewLog{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    JKLogFileListViewController *logFileListVC = [JKLogFileListViewController new];
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:logFileListVC];
    naVC.modalPresentationStyle = UIModalPresentationFullScreen;
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

+ (NSArray *)files
{
    return [JKLogHelper shareInstance].files;
}


#pragma mark - - - - getter - - - -
- (NSString *)folderPath{
    if (!_folderPath) {
        _folderPath = [JKSandBoxManager createDocumentsFilePathWithFolderName:@"JKLogHelper_logs"];
    }
    return _folderPath;
}

@end
