//
//  JKLogHelper.h
//  JKLogHelper
//
//  Created by JackLee on 2019/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKLogHelper : NSObject

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)shareInstance;

/**
 start monitor the log and write the log to the file
 */
+ (void)start;

/**
 delete all the logFiles
 */
+ (void)deleteAllLogFiles;


/**
 get all the filePath of the logFiles

 @return the array of log file name
 */
+ (NSArray <NSString *>*)getLogFiles;


/**
 open the logFile list
 */
+ (void)viewLog;

@end

NS_ASSUME_NONNULL_END
