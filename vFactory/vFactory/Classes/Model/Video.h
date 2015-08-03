//
//  Video.h
//  Doco
//
//  Created by developer on 15/4/15.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kDirectionVertical = 0, //垂直方向（竖屏）
    kDirectionHorizontal = 1 //水平方向（横屏）
} directionType;

typedef enum {
    kIsPrivateNo = 0, //公开
    kIsPrivateYes = 1 //私密
} isPrivate;

typedef enum {
    kIsEditorChoiceNo = 0, //不是精选
    kIsEditorChoiceYes = 1 //是精选
} isEditorChoice;

typedef enum {
    kIsTopVideoNo = 0, //不是置顶
    kIsTopVideoYes = 1 //是置顶
} isTopVideo;

typedef enum {
    kTimeHiddenYes = 0, //时间隐藏
    kTimeHiddenNo = 1 //时间显示
} timeHidden;

typedef enum {
    kAllowToRecommendNo = 0, //不允许
    kAllowToRecommendYes = 1 //允许
} allowToRecommend;

@interface Video : NSObject
@property (nonatomic, assign) int videoId; //视频Id
@property (nonatomic, assign) int userId; //用户ID
@property (nonatomic, assign) int classificationId; //类别Id
@property (nonatomic, copy) NSString *name; //名称
@property (nonatomic, copy) NSString *userName; //用户昵称
@property (nonatomic, copy) NSString *userPortrait; //用户头像

@property (nonatomic, copy) NSString *cover; //封面

@property (nonatomic, assign) directionType directionTpye; //视频方向（横屏竖屏）
@property (nonatomic, assign) isPrivate isPrivate; //是否私密
@property (nonatomic, assign) timeHidden timeHidden; //时间是否隐藏
@property (nonatomic, assign) isEditorChoice isEditorChoice; //是否是精选
@property (nonatomic, assign) isTopVideo isTopVideo; //是否是置顶视频
@property (nonatomic, assign) allowToRecommend allowToRecommend; //allow_to_recommend是否允许后台工作人员将视频上传到推荐

@property (nonatomic, assign) CGFloat duration; //持续时间
@property (nonatomic, copy) NSString *descriptionText; //视频描述

@property (nonatomic, copy) NSString *createTime; //创建时间

@property (strong, nonatomic) NSURL *fileURL; //视频路径
@property (copy, nonatomic) NSString *filePath; //视频路径

@property (nonatomic, assign) int zanCount; //赞数
@property (nonatomic, copy) NSString *lbs; //位置
@property (nonatomic, assign) int commentCount; //评论数
@property (nonatomic, assign) int clicksCount; //播放量/点击量
@property (nonatomic, assign) int fps;//帧率
@property (nonatomic, copy) NSString *resolution; //分辨率
@property (nonatomic, copy) NSString *extensionName; //格式
@property (nonatomic, assign) int bitrate; //比特率
@property (nonatomic, copy) NSString *hashTagList; //话题列表
//@property (nonatomic, copy) NSString *tagList; //标签列表
@property (nonatomic, copy) NSString *keyFrameList; //关键帧列表

@property (nonatomic, assign) int position; //精选视频位置


@property (nonatomic, copy) NSString *createTimeTrans; //时间转换（保存最原始的没有转换格式的时间）


- (id)initWithDict:(NSDictionary *)dict;
@end
