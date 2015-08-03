//
//  FileTool.m
//  doco_ios_app
//
//  Created by developer on 15/5/4.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "FileTool.h"
#import "CommonTool.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation FileTool
+ (BOOL)createVideoFolderIfNotExist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *folderPath = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    return [CommonTool createFolderIfNotExistForFolderPath:folderPath];
}

+ (NSString *)getVideoMergeFilePathStringWithFolderPath:(NSString *)folderPath
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[folderPath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mov"];
    
    return fileName;
}

+ (NSString *)getVideoSaveFilePathStringWithFolderPath:(NSString *)folderPath
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[folderPath stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mov"];
    
    return fileName;
}

+ (NSString *)getSaveFolderPathStringWithFolderName:(NSString *)folderName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:folderName];
    
    return path;
}

//复制所有文件到目录
+(BOOL)moveFiles:(NSArray *)pathArray toPath:(NSArray *)dstArray{
    
    for(int i=0;i<pathArray.count;i++){
        NSError *error;
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:dstArray[i]]) {
            MyLog(@"文件已经存在！不用存了");
            return YES;
            
        }
        BOOL isSuccess = [fm moveItemAtPath:pathArray[i] toPath:dstArray[i] error:&error];
        if (!isSuccess) {
            return NO;
        }
    }
    return YES;
}

+ (NSString *)getVideoSaveFolderPathString
{
    
    return [self getSaveFolderPathStringWithFolderName:VIDEO_FOLDER];
}

+(NSString *)getVideoSavePathString{
    NSString *videoFolder = [self getVideoSaveFolderPathString];
    NSString *videoPath = [self getVideoSaveFilePathStringWithFolderPath:videoFolder];
    return videoPath;
}

+(NSString *)getFilePathFromFileURL:(NSURL *)fileURL{
    NSMutableString *filePath = [NSMutableString stringWithString:[fileURL absoluteString]];
    [filePath replaceCharactersInRange:NSMakeRange(0, 7) withString:@""];
    
    return filePath;
}

//删除文件
+ (void) removeFile:(NSURL *)fileURL
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [[fileURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:filePath error:&error];
            if (error) {
                MyLog(@"删除失败：%@",error);
            }
            
        }
    });
    
}
+(BOOL)fileIsExistAtPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}
+(void) removeFiles:(NSArray *)urlArray{
    
    for (NSURL *fileURL in urlArray) {
        [self removeFile:fileURL];
    }
}
@end
