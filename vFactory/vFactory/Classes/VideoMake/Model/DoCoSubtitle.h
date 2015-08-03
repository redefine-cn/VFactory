//
//  DoCoSubtitle.h
//  doco_ios_app
//
//  Created by developer on 15/6/12.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoCoSubtitle : NSObject
@property(nonatomic,copy)NSString *textName;
@property(nonatomic,assign)int maxNum;
@property(nonatomic,assign)BOOL isShow;
@property(nonatomic,copy)NSString *text;
@end
