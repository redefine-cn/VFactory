//
//  CommonTool.m
//  doco_ios_app
//
//  Created by developer on 15/4/18.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "CommonTool.h"

@implementation CommonTool
+(NSArray *)loadPlistWithPath:(NSString *)plistPath{
    //读取文件内容
    NSArray *data = [NSArray arrayWithContentsOfFile:plistPath];

    return data;
}

+(BOOL)writePlistAtPath:(NSString *)plistPath Add:(NSObject *)object num:(int)num{
    
    NSMutableArray *datas = [NSMutableArray arrayWithContentsOfFile:plistPath];
    if (!datas) {
        datas = [[NSMutableArray alloc]init];
    }
    if (num>=0 && datas.count>0) {
        [datas removeObjectAtIndex:num];
    }
    [datas addObject:object];
    
    return [datas writeToFile:plistPath atomically:YES];
}

+ (BOOL)createFolderIfNotExistForFolderPath:(NSString *)folderPath
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            MyLog(@"创文件夹失败");
            return NO;
        }
        return YES;
    }
    return YES;
}


+ (BOOL)createFileIfNotExistForFilePath:(NSString *)filePath
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    
    BOOL isFileExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    
    if(!isFileExist && !isDir)
    {
        BOOL bCreateDir = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        if(!bCreateDir){
            MyLog(@"创文件失败");
            return NO;
        }
        return YES;
    }
    MyLog(@"不用创建了");
    return YES;
}

//获取临时文件夹路径
+(NSString *)getTempFolder{
    return NSTemporaryDirectory();
}

+(NSString *)getTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    return nowTimeStr;
}

+ (void)saveObject:(NSObject *)object toFile:(NSString *)filePath
{
    [NSKeyedArchiver archiveRootObject:object toFile:filePath];
}

+(BOOL)saveImageAndTransformToPNGForImage:(UIImage *)image toFolder:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        //如果图片存在  先删除
        NSError *error = nil;
        [fileManager removeItemAtPath:filePath error:&error];
        if (error) {
            MyLog(@"删除失败%@",error);
        }
    }
    NSData *data;
    if (UIImagePNGRepresentation(image)==nil) {//如果不是png格式
        data = UIImageJPEGRepresentation(image, 1);
    }else{//如果是png
        data = UIImagePNGRepresentation(image);
    }
    
    BOOL success = [fileManager createFileAtPath:filePath contents:data attributes:nil];
    return success;
    
}

//获取当前时区
+ (NSDate *)nowDate

{
    
    NSDate *date = [NSDate date];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: date];
    
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    return localeDate;
    
}

@end
