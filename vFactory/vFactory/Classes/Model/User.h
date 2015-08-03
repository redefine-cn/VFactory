//
//  User.h
//  Doco
//
//  Created by developer on 15/4/15.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSexTypeMale = 0, //男
    kSexTypeFemale = 1, //女
    kSexTypeUnknown = 2 //未知
} sexType;

@interface User : NSObject
@property (nonatomic, assign) int userId; //用户Id
@property (nonatomic, assign) sexType sex; //性别 （0 男，1女）
@property (nonatomic, assign) int age; //年龄
@property (nonatomic, copy) NSString *birthday; //生日
@property (nonatomic, copy) NSString *userName; //用户名
@property (nonatomic, copy) NSString *signature; //个性签名
@property (nonatomic, copy) NSString *portrait; //头像图片
@property (nonatomic, copy) NSString *password; //密码
@property (nonatomic, copy) NSString *email; //邮箱

@property (nonatomic, copy) NSString *backgroundImage; //个人主页背景图片

@property (nonatomic, assign) int userStatus; //用户登录状态

@property (nonatomic, copy) NSString *registeredDate; //注册日期
@property (nonatomic, copy) NSDate *lastLogin; //上次登录时间
@property (nonatomic, copy) NSString *phone; //手机号
@property (nonatomic, copy) NSString *college; //大学
@property (nonatomic, copy) NSString *highSchool; //高中
@property (nonatomic, copy) NSString *location; //所在地

//@property (nonatomic, assign) int topVideoId; //置顶视频Id
//@property (nonatomic, copy) NSDate *lastVideoUpdate; //最后更新时间

@property (nonatomic, assign) int followingCount; //关注数
@property (nonatomic, assign) int followerCount; //粉丝数

@property (nonatomic, assign) int videoCount; //视频数
@property (nonatomic, assign) int totalUpdate; //好友本周更新数

//@property (nonatomic, copy) NSString *friendList; //好友列表
//@property (nonatomic, copy) NSString *scriptList; //脚本列表


- (id)initWithDict:(NSDictionary *)dict;
@end