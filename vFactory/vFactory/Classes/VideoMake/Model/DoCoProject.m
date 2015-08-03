//
//  DoCoProject.m
//  doco_ios_app
//
//  Created by developer on 15/5/1.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "DoCoProject.h"

@implementation DoCoProject
//从草稿箱初始化
-(instancetype)initWithArray:(NSArray *)array{
    self = [super init];
    if (self) {

        _partArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _partArray = [[NSMutableArray alloc]init];
        _hasBg = YES;
    }
    return self;
}
@end
