//
//  Video.m
//  Doco
//
//  Created by developer on 15/4/15.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "Video.h"

@implementation Video
- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.videoId = [dict[@"video_id"] intValue];
        self.userId = [dict[@"user_id"] intValue];
        self.userName = dict[@"user_name"];
        self.userPortrait = dict[@"user_portrait"];
        self.classificationId = [dict[@"classification_id"] intValue];
        self.name = dict[@"name"];
        self.cover = dict[@"cover"];
        self.duration = [dict[@"duration"] floatValue];
        self.descriptionText = dict[@"description"];
        self.createTime = dict[@"create_time"];
        self.fileURL = dict[@"url"];
        self.filePath = dict[@"url"];
        self.zanCount = [dict[@"like_count"] intValue];
        self.lbs = dict[@"lbs"];
        self.commentCount = [dict[@"comment_count"] intValue];
        self.clicksCount = [dict[@"clicks"] intValue];
        self.fps = [dict[@"fps"] intValue];
        self.resolution = dict[@"resolution"];
        self.extensionName = dict[@"extension_name"];
        self.bitrate = [dict[@"bit_rate"] intValue];
        self.hashTagList = dict[@"hash_tag_list"];
        self.keyFrameList = dict[@"key_frame_list"];
        
        self.isPrivate = [dict[@"is_private"] intValue];
        self.isEditorChoice = [dict[@"is_editor_choice"] intValue];
        self.timeHidden = [dict[@"is_up_to_date"] intValue];
        self.directionTpye = [dict[@"is_cross_screen"] intValue];
        self.isTopVideo = [dict[@"is_top_video"] intValue];
        self.allowToRecommend = [dict[@"allow_to_recommend"] intValue];
        
        self.position = [dict[@"position"] intValue];
        self.createTimeTrans = dict[@"create_time"];
    }
    return self;
}

//重写createTime的get方法
- (NSString *)createTime
{
    //1.将时间字符串转为NSDate对象
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    //使字符串能够在任何语言环境下解析
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDate *date = [fmt dateFromString:_createTime];
    //MyLog(@"%@", date);
    
    fmt.dateFormat = @"yyyy / MM / dd";
    return [NSString stringWithFormat:@"%@ 上传",[fmt stringFromDate:date]];
}

- (NSString *)lbs
{
//    MyLog(@"lbs:%@", _lbs);
    if (_lbs == (id)[NSNull null]) {
        return @"UnKnown";
    }
    return _lbs;
}
@end

