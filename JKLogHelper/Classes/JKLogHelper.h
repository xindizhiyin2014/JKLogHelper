//
//  JKLogHelper.h
//  JKLogHelper
//
//  Created by JackLee on 2019/6/20.
//

#import <Foundation/Foundation.h>

#define LEFLog(fmt, ...) NSLog((@"%@, %s (%d) => " fmt), [JKLogHelper lastCallMethod], __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__

NS_ASSUME_NONNULL_BEGIN

@interface JKLogHelper : NSObject

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;



/**
 start monitor the log and write the log to the file
 */
+ (void)start;

/**
 config the max num of the log file,default is 30

 @param maxLogs default is 30
 */
+ (void)configMaxLogFiles:(NSInteger)maxLogs;

/**
 delete all the logFiles
 */
+ (void)deleteAllLogFiles;


/**
 get all the filePath of the logFiles

 @return the array of log file name
 */
+ (NSArray <NSString *>*)getLogFiles;

+ (NSString *)folderPath;

/**
 open the logFile list
 */
+ (void)viewLog;

/**
can log the last method of the func
thanks the author Lefe_x https://weibo.com/u/5953150140
@return log
*/
+ (NSString *)lastCallMethod;

/// the array of fileName
+ (NSArray *)files;

@end

NS_ASSUME_NONNULL_END
