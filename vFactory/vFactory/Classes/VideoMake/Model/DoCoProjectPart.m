//
//  DoCoProjectPart.m
//  doco_ios_app
//
//  Created by developer on 15/5/9.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "DoCoProjectPart.h"

@implementation DoCoProjectPart

-(instancetype)init{
    self = [super init];
    if (self) {
        _subtitles = [[NSMutableArray alloc]init];
        self.isSelected = YES;
    }
    return self;
}


@end
