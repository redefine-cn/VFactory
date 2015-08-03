//
//  CommonTool.h
//  doco_ios_app
//
//  Created by developer on 15/4/18.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "FileTool.h"

@interface CommonTool : NSObject
+(NSArray *)loadPlistWithPath:(NSString *)plistPath;

+(BOOL)writePlistAtPath:(NSString *)plistPath Add:(NSObject *)object num:(int)num;

+ (BOOL)createFolderIfNotExistForFolderPath:(NSString *)folderPath;

+ (void)saveObject:(NSObject *)object toFile:(NSString *)filePath;

+ (BOOL)createFileIfNotExistForFilePath:(NSString *)filePath;

+(NSString *)getTimestamp;

+(BOOL)saveImageAndTransformToPNGForImage:(UIImage *)image toFolder:(NSString *)filePath;

//获取当前时间
+ (NSDate *)nowDate;
@end
