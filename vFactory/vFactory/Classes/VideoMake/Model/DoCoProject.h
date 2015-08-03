//
//  DoCoProject.h
//  doco_ios_app
//
//  Created by developer on 15/5/1.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "DoCoProjectPart.h"

typedef enum {
    DoCoProjectTypeCapture,
    DoCoProjectTypeEdit,
    DoCoProjectTypeFinish,
    DoCoProjectTypeUpload,
} DoCoProjectType;

@interface DoCoProject : NSObject
@property(nonatomic,copy)NSString *scriptName;
@property(nonatomic,strong)NSDate *createTime;
@property(nonatomic,strong)NSDate *lastEditTime;
@property(nonatomic,copy)NSString *projectName;//工程名
@property(nonatomic,copy)NSString *folderPath;//文件夹路径  完整路径
@property(nonatomic,copy)NSString *coverPath;
@property(nonatomic,copy)NSString *LBS;
@property(nonatomic,assign)DoCoProjectType type;//保存的类型（位置）
@property(nonatomic,strong)UIImage *coverImage;

@property(nonatomic,copy)NSString *bgMusicName;

@property(nonatomic,copy)NSString *videoKey;

@property(nonatomic,assign)int num;//用于记录在草稿箱中的位置，方便修改，最后保存时才会用到，由草稿箱赋值

@property(nonatomic,strong)NSURL *okVideoURL;//成品视频路径

@property(nonatomic,assign)BOOL isPortrait;

@property(nonatomic,assign)BOOL isNew;//是否是新建的工程

@property(nonatomic,strong)NSMutableArray *partArray;

@property(nonatomic,assign)float frameTime;//要截取的封面时间点
//记录是否有背景音乐  （改为了降低音量）
@property(nonatomic,assign)BOOL hasBg;

-(instancetype)initWithArray:(NSArray *)array;
@end
