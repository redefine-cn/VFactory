//
//  DoCoProjectPart.h
//  doco_ios_app
//
//  Created by developer on 15/5/9.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoCoSubtitle.h"

@interface DoCoProjectPart : NSObject
@property(nonatomic,copy)NSString *partName;
@property(nonatomic,copy)NSString *videoPath;//拍摄的video
@property(nonatomic,strong)UIImage *image;//导入或者拍摄的照片
@property(nonatomic,copy)NSString *imagePath;//这是导入的图片 预览imageURL
@property(nonatomic,copy)NSString *makeLBS;
@property(nonatomic,assign)float assetTime;//总得时间
@property(nonatomic,assign)float startTime;
@property(nonatomic,assign)float endTime;
@property(nonatomic,assign)float minTime;
@property(nonatomic,assign)float maxTime;
@property(nonatomic,strong)NSURL *okVideoUrl;//合成的video

@property(nonatomic,assign)BOOL isSelected;//记录是否被选择
@property(nonatomic,strong)UIImage *previewImage;//选择界面的Image
@property(nonatomic,copy)NSString *previewVideo;

@property(nonatomic,strong)UIImage *overlayImage;//蒙版image
@property(nonatomic,copy)NSString *overlayImagePath;//蒙版imagePath

@property(nonatomic,strong)NSMutableArray *subtitles;//字幕组（用于实例化界面）

@end
