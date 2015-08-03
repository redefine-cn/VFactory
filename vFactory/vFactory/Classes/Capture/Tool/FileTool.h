//
//  FileTool.h
//  doco_ios_app
//
//  Created by developer on 15/5/4.
//  Copyright (c) 2015年 developer. All rights reserved.
//

typedef void (^successBlock)(NSURL* url);
typedef void (^failureBlock)(NSError* error);
@interface FileTool : NSObject
+ (BOOL)createVideoFolderIfNotExist;
+ (NSString *)getVideoSaveFilePathStringWithFolderPath:(NSString *)folderPath;
+(BOOL)fileIsExistAtPath:(NSString *)path;
+ (NSString *)getVideoMergeFilePathStringWithFolderPath:(NSString *)folderPath;
//+ (NSString *)getVideoSaveFolderPathString;
+ (NSString *)getFilePathFromFileURL:(NSURL *)fileURL;
//获取视频文件存储路径  在videos文件夹中
+(NSString *)getVideoSavePathString;

//获取文件夹路径
+ (NSString *)getSaveFolderPathStringWithFolderName:(NSString *)folderName;
//移动一堆文件到某个文件夹  会自动判断是否存在
+(BOOL)moveFiles:(NSArray *)pathArray toPath:(NSArray *)dstArray;
//删除文件
+(void) removeFile:(NSURL *)fileURL;
+(void) removeFiles:(NSArray *)urlArray;

@end
