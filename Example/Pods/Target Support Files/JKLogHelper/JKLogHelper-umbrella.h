#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ICPreprocessor.h"
#import "ICRangeUtils.h"
#import "ICRegularExpression.h"
#import "ICTextView.h"
#import "JKLogFileListViewController.h"
#import "JKLogHelper.h"
#import "JKLogViewController.h"

FOUNDATION_EXPORT double JKLogHelperVersionNumber;
FOUNDATION_EXPORT const unsigned char JKLogHelperVersionString[];

