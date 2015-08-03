//
//  User.m
//  Doco
//
//  Created by developer on 15/4/15.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "User.h"

@implementation User
- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        
        self.userId = [dict[@"id"] intValue];
        self.sex = [dict[@"sex"] intValue];
        self.age = [dict[@"age"] intValue];
        self.birthday = dict[@"birthday"];
        self.userName = dict[@"username"];
        self.signature = dict[@"signature"];
        self.portrait = dict[@"portrait"];
        self.password = dict[@"password"];
        self.email = dict[@"email"];
        self.backgroundImage = dict[@"background"];
        
        self.userStatus = [dict[@"user_status"] intValue];
        self.registeredDate = dict[@"registered_date"];
        self.lastLogin = dict[@"last_login"];
        self.phone = dict[@"phone"];
        self.college = dict[@"college"];
        self.highSchool = dict[@"high_school"];
        self.location = dict[@"location"];
        self.followerCount = [dict[@"follower_count"] intValue];
        self.followingCount = [dict[@"following_count"] intValue];
        self.videoCount = [dict[@"video_count"] intValue];
        self.totalUpdate = [dict[@"total_update"] intValue];
        
//        self.topVideoId = [dict[@"top_video_id"] intValue];
//        self.lastVideoUpdate = dict[@"last_video_update"];
        
//        self.followingCount = [dict[@"followers_count"] intValue];
//        self.followMeCount = [dict[@"friends_count"] intValue];
    }
    return self;
}


- (int)age
{
    return _age;
}
- (NSString *)birthday
{
    return _birthday == (id)[NSNull null]?@"":_birthday;
}
- (NSString *)signature
{
 return _signature == (id)[NSNull null]?@"":_signature;
}
- (NSString *)phone
{
    return _phone == (id)[NSNull null]?@"":_phone;
}
- (NSString *)college
{
    return _college == (id)[NSNull null]?@"":_college;
}
- (NSString *)highSchool
{
    return _highSchool == (id)[NSNull null]?@"":_highSchool;
}
- (NSString *)location
{
    return _location == (id)[NSNull null]?@"":_location;
}
- (NSString *)email
{
    return _email == (id)[NSNull null]?@"":_email;
}

@end
