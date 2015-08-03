//
//  MyProgress.h
//  doco_ios_app
//
//  Created by developer on 15/6/10.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    MyProgressStyleNormal,
    MyProgressStyleDelete,
    MyProgressStyleToMinTime,
    MyProgressStyleToMaxTime,
} MyProgressStyle;

@interface MyProgress : UIView

@property(nonatomic,assign)float minDuration;
@property(nonatomic,assign)float maxDuration;
@property(nonatomic,copy)NSString *labelText;
@property(nonatomic,strong)UIColor *backColor;
@property(nonatomic,strong)UIColor *foreColor;
@property (strong,nonatomic)UILabel *label;
@property(nonatomic,assign)BOOL selected;

- (id)initWithFrame:(CGRect)frame minDuration:(float)min maxDuration:(float)max;

- (void)setProgressToStyle:(MyProgressStyle)style;
- (void)setProgressToTime:(float)time;

-(void)deleteProgress;
@end
